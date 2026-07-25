install:
	pip install --upgrade pip && \
	pip install -r requirements.txt

format:
	black *.py

train:
	mkdir -p Results
	mkdir -p Model
	python train.py

eval:
	echo "## Model Metrics" > report.md
	cat ./Results/metrics.txt >> report.md
	echo "" >> report.md
	echo "## Confusion Matrix Plot" >> report.md
	echo "![Confusion Matrix](./Results/model_results.png)" >> report.md
	cml comment create report.md

update-branch:
	git config --global user.name "$(USER_NAME)"
	git config --global user.email "$(USER_EMAIL)"
	git add .
	git commit -m "Update with new results" || echo "No changes to commit"
	git push --force origin HEAD:update

hf-login:
	git pull origin update
	git switch update
	pip install -U "huggingface_hub[cli]"
	hf auth login --token $(HF) --add-to-git-credential

push-hub:
	hf upload iqranaz/Drug-Classification ./App --repo-type=model --commit-message="Sync App files"
	hf upload iqranaz/Drug-Classification ./Model /Model --repo-type=model --commit-message="Sync Model"
	hf upload iqranaz/Drug-Classification ./Results /Metrics --repo-type=model --commit-message="Sync Metrics"

deploy: hf-login push-hub