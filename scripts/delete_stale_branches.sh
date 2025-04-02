#!/bin/bash

set -eo pipefail

# Set the log level (can be "INFO" or "DEBUG")
LOG_LEVEL=${LOG_LEVEL:-INFO}

# Color definitions for log levels
COLOR_INFO='\033[0;32m'  # Green for INFO
COLOR_DEBUG='\033[0;34m' # Blue for DEBUG
COLOR_ERROR='\033[0;31m' # Red for ERROR
COLOR_RESET='\033[0m'    # Reset to default color

deleted_branches=()
deleted_releases=()

# Logger function to log messages based on log level
log_message() {
	local level=$1
	local message=$2

	# Set color based on log level
	local color
	case "${level}" in
	"INFO") color="${COLOR_INFO}" ;;
	"DEBUG") color="${COLOR_DEBUG}" ;;
	"ERROR") color="${COLOR_ERROR}" ;;
	*) color="${COLOR_RESET}" ;;
	esac

	# Check if the message's level should be printed based on the current log level
	if [[ "${level}" == "DEBUG" && "${LOG_LEVEL}" == "INFO" ]]; then
		return 0
	fi

	# Log to console with color
	echo -e "${color}[${level}] - ${message}${COLOR_RESET}"
}

# Validate environment variables
[[ -n ${DATE} ]] || {
	log_message "ERROR" "Please specify a suitable date input for branch filtering"
	exit 0
}

DRY_RUN=${DRY_RUN:-true}
DELETE_TAGS=${DELETE_TAGS:-false}
MINIMUM_TAGS=${MINIMUM_TAGS:-0}
DEFAULT_BRANCHES=${DEFAULT_BRANCHES},main,master,develop,gh-pages,dev,development,release
EXCLUDE_BRANCH_REGEX=${EXTRA_PROTECTED_BRANCH_REGEX:-^$}
EXCLUDE_TAG_REGEX=${EXTRA_PROTECTED_TAG_REGEX:-^$}
EXCLUDE_OPEN_PR_BRANCHES=${EXCLUDE_OPEN_PR_BRANCHES:-true}
DELETE_RELEASES=${DELETE_RELEASES:-false}

log_message "INFO" "Started cleanup process"
log_message "INFO" "Dry run mode: ${DRY_RUN}"

# Fetch open PR branches once
open_prs_branches=$(gh api "repos/${GITHUB_REPOSITORY}/pulls" --jq '.[].head.ref' --paginate)
releases=$(gh api "repos/${GITHUB_REPOSITORY}/releases" --jq '.[]')

default_branch_protected() {
	local br=${1}

	local default_branches
	default_branches=$(echo "${DEFAULT_BRANCHES}" | tr "," "\n")

	for default_branch in $default_branches; do
		if [[ "${br}" == "${default_branch}" ]]; then
			return 0
		fi
	done

	return 1
}

delete_releases_with_notags() {
	log_message "INFO" "Checking for releases with no tags or deleted tags..."
	# Iterate over each release
	echo "$releases" | while IFS= read -r release; do
		release_tag=$(echo "$release" | jq -r '.tag_name')
		# Check if the release has no tag or if the tag is deleted
		if [[ (-z "$release_tag" || -z "$(git ls-remote --tags origin "$release_tag")") && "$release_tag" != "" ]]; then
			if [[ "${DRY_RUN}" == false ]]; then
				# Delete the release
				log_message "INFO" "Release for tag ${release_tag} deleted successfully"
				if ! gh release delete "${release_tag}" --yes; then
					log_message "ERROR" "Failed to delete release for tag: ${release_tag}. Continuing with next release."
				else
					log_message "INFO" "Release for tag ${release_tag} deleted successfully"
				fi
			else
				log_message "INFO" "Dry run mode: Release for tag ${release_tag} would be deleted"
			fi
			deleted_releases+=("${release_tag}")
			continue
		fi
	done
}

extra_branch_or_tag_protected() {
	local br=${1} ref="${2}"

	if [[ "${ref}" == "branch" ]]; then
		echo "${br}" | grep -qE "${EXCLUDE_BRANCH_REGEX}"
	elif [[ "${ref}" == "tag" ]]; then
		echo "${br}" | grep -qE "${EXCLUDE_TAG_REGEX}"
	fi

	return $?
}

is_pr_open_on_branch() {
	if [[ "${EXCLUDE_OPEN_PR_BRANCHES}" == false ]]; then
		return 1
	fi

	local br=${1}

	# Check if the branch is in the list of open PR branches
	for pr_br in ${open_prs_branches}; do
		if [[ "${pr_br}" == "${br}" ]]; then
			return 0
		fi
	done

	return 1
}

delete_branch_or_tag() {
	local br=${1} ref="${2}" sha="${3}"
	deleted_branches+=("${br}")

	log_message "INFO" "Deleting branch: ${br}"

	if [[ "${DRY_RUN}" == false ]]; then
		if ! git branch -D "${br}"; then
			log_message "ERROR" "Failed to delete local branch: ${br}. Continuing with next branch."
		fi

		# Try to delete the branch remotely
		if ! git push origin --delete "${br}"; then
			log_message "ERROR" "Failed to delete remote branch: ${br}. Continuing with next branch."
		fi

		log_message "INFO" "Branch ${br} deleted successfully"
	else
		log_message "INFO" "Dry run mode: Branch ${br} would be deleted"
	fi
}

delete_release_for_tag() {
	local tag=$1

	# Find the release corresponding to the tag
	release_tag=$(echo "$releases" | jq -r ". | select(.tag_name == \"${tag}\") | .tag_name")

	if [[ -n "$release_tag" ]]; then
		log_message "INFO" "Tag ${tag} deleted. Deleting corresponding release ${release_tag}."

		if [[ "${DRY_RUN}" == false ]]; then
			# Delete the release
			if ! gh release delete "${release_tag}" --yes; then
				log_message "ERROR" "Failed to delete release for tag: ${release_tag}. Continuing with next release."
			else
				log_message "INFO" "Release for tag ${release_tag} deleted successfully."
			fi
		else
			log_message "INFO" "Dry run mode: Release for tag ${release_tag} would be deleted."
		fi
		deleted_releases+=("${release_tag}")
	else
		log_message "INFO" "No corresponding release found for tag ${tag}."
	fi
}

main() {
	for br in $(git ls-remote -q --heads --refs | sed "s@^.*heads/@@"); do
		log_message "DEBUG" "Checking branch: ${br}"

		if [[ -z "$(git log --oneline -1 --since="${DATE}" origin/"${br}")" ]]; then
			sha=$(git show-ref -s "origin/${br}")

			if default_branch_protected "${br}"; then
				log_message "DEBUG" "Branch: ${br} is a default branch. Won't delete it"
				continue
			fi

			if extra_branch_or_tag_protected "${br}" "branch"; then
				log_message "DEBUG" "Branch: ${br} is explicitly protected. Won't delete it"
				continue
			fi

			if is_pr_open_on_branch "${br}"; then
				log_message "DEBUG" "Branch: ${br} has an open pull request. Won't delete it"
				continue
			fi

			delete_branch_or_tag "${br}" "heads" "${sha}"
		fi
	done

	log_message "INFO" "Deleted branches: ${deleted_branches[*]}"
	echo "::warning::Deleting stale branches ${deleted_branches[*]}. \
If you want to protect any branch from deletion please set EXTRA_PROTECTED_BRANCH_REGEX in github workflow as directed in the documentation \
https://dx.docs.usxpress.io/build/protect-stale-branches/"

	if [[ "${DELETE_TAGS}" == true ]]; then
		local tag_counter=1
		for br in $(git for-each-ref --sort=-creatordate --format '%(refname)' refs/tags | sed "s@^.*tags/@@"); do
			if [[ ${tag_counter} -gt ${MINIMUM_TAGS} ]]; then
				if extra_branch_or_tag_protected "${br}" "tag"; then
					log_message "DEBUG" "Tag: ${br} is explicitly protected. Won't delete it"
					continue
				fi
				delete_branch_or_tag "${br}" "tags"
				delete_release_for_tag "${br}"
			else
				log_message "DEBUG" "Not deleting tag ${br} due to minimum tag requirement (min: ${MINIMUM_TAGS})"
				((tag_counter += 1))
			fi
		done
	fi
	# This is to delete releases with no Tags
	if [[ "${DELETE_RELEASES}" == true ]]; then
		delete_releases_with_notags
	fi

}

main "$@"
