# Copyright (C) 2020-2021 Nicolas Lamirault <nicolas.lamirault@gmail.com>

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

include hack/commons.mk

# ====================================
# D E V E L O P M E N T
# ====================================

##@ Development

.PHONY: clean
clean: ## Cleanup
	@echo -e "$(OK_COLOR)[$(BANNER)] Cleanup$(NO_COLOR)"
	@find . -name "*.retry"|xargs rm -f

.PHONY: check
check: check-poetry check-helm ## Check requirements

.PHONY: init ## Initialize environment
init:
	poetry install
	$(ANSIBLE_VENV)/bin/pre-commit install

# ====================================
# H E L M
# ====================================

##@ Helm

.PHONY: helm-doc
helm-doc: guard-CHART ## Generate documentation
	cd $(CHART) && helm-docs 

.PHONY: helm-template
helm-template: guard-CHART ## Generate manifest
	helm template $(CHART)

.PHONY: helm-policy
helm-policy: guard-CHART guard-POLICY ## Check manifest
	helm template $(CHART) | conftest test -p $(POLICY) -


# ====================================
# O P A
# ====================================

##@ Opa

.PHONY: opa-deps
opa-deps: ## Setup OPA dependencies
	@echo -e "$(OK_COLOR)[$(APP)] Install OPA policy $(POLICY)$(NO_COLOR)"
	conftest pull --policy addons/policies/instrumenta github.com/instrumenta/policies.git//kubernetes
	conftest pull --policy addons/policies/deprek8ion github.com/swade1987/deprek8ion//policies

.PHONY: opa-install
opa-install: guard-NAME guard-URL ## Install OPA policies
	@echo -e "$(OK_COLOR)[$(APP)] Install OPA policy $(POLICY)$(NO_COLOR)"
	conftest pull --policy addons/policies/$(NAME) $(URL)