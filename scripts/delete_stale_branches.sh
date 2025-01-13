#!/bin/bash

set -eo pipefail

# Validate environment variables
[[ -n ${DATE} ]] || {
	echo -e "${RED}[ERROR] Please specify a suitable date input for branch filtering${RESET}"
	exit 0
}
# Red color escape code
RED='\033[0;31m'
# Reset color escape code
RESET='\033[0m'

DRY_RUN=${DRY_RUN:-true}
DELETE_TAGS=${DELETE_TAGS:-false}
MINIMUM_TAGS=${MINIMUM_TAGS:-0}
DEFAULT_BRANCHES=${DEFAULT_BRANCHES},main,master,develop
EXCLUDE_BRANCH_REGEX=${EXTRA_PROTECTED_BRANCH_REGEX:-^$}
EXCLUDE_TAG_REGEX=${EXTRA_PROTECTED_TAG_REGEX:-^$}
EXCLUDE_OPEN_PR_BRANCHES=${EXCLUDE_OPEN_PR_BRANCHES:-true}

echo "[INFO] Started cleanup process"
echo "[INFO] Dry run mode: ${DRY_RUN}"

deleted_branches=()

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
	open_prs_branches=$(gh api "repos/${GITHUB_REPOSITORY}/pulls" --jq '.[].head.ref' --paginate)

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

	echo "[INFO] Deleting branch: ${br}"

	if [[ "${DRY_RUN}" == false ]]; then
		if ! git branch -D "${br}"; then
			echo -e "${RED}[ERROR] Failed to delete local branch: ${br}. Continuing with next branch.${RESET}"
		fi

		# Try to delete the branch remotely
		if ! git push origin --delete "${br}"; then
			echo -e "${RED}[ERROR] Failed to delete remote branch: ${br}. Continuing with next branch.${RESET}"
		fi

		echo "[INFO] Branch ${br} deleted successfully"
	else
		echo "[INFO] Dry run mode: Branch ${br} would be deleted"
	fi
}

main() {
	for br in $(git ls-remote -q --heads --refs | sed "s@^.*heads/@@"); do
		if [[ -z "$(git log --oneline -1 --since="${DATE}" origin/"${br}")" ]]; then
			sha=$(git show-ref -s "origin/${br}")

			if default_branch_protected "${br}"; then
				echo "[INFO] Branch: ${br} is a default branch. Won't delete it"
				continue
			fi

			if extra_branch_or_tag_protected "${br}" "branch"; then
				log INFO "Branch: ${br} is explicitly protected. Won't delete it"
				continue
			fi

			if is_pr_open_on_branch "${br}"; then
				echo "[INFO] Branch: ${br} has an open pull request. Won't delete it"
				continue
			fi

			delete_branch_or_tag "${br}" "heads" "${sha}"
		fi
	done

	echo "[INFO] Deleted branches: ${deleted_branches[*]}"

	if [[ "${DELETE_TAGS}" == true ]]; then
		local tag_counter=1
		for br in $(git ls-remote -q --tags --refs | sed "s@^.*tags/@@" | sort -rn); do
			if [[ -z "$(git log --oneline -1 --since="${DATE}" "${br}")" ]]; then
				if [[ ${tag_counter} -gt ${MINIMUM_TAGS} ]]; then
					if extra_branch_or_tag_protected "${br}" "tag"; then
						echo "[INFO] Tag: ${br} is explicitly protected. Won't delete it"
						continue
					fi
					delete_branch_or_tag "${br}" "tags"
				else
					echo "[INFO] Not deleting tag ${br} due to minimum tag requirement (min: ${MINIMUM_TAGS})"
					((tag_counter += 1))
				fi
			fi
		done
	fi
}

main "$@"
