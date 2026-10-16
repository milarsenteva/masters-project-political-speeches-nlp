# Two Narratives: Comparing Domestic and International Framing of Political Speeches

An NLP research project comparing how Italy discusses **migration** and **military and defense policy** in domestic parliamentary debates and international UN speeches between **2006 and 2022**.

The project combines multilingual BERT classification, LDA topic modeling, Italian-to-English translation, and hierarchical summarization to examine differences across institutional settings, political groups, and time.

**Authors:** Milana Arsenteva, Anna Ciapparelli, Sara Pulidori, and Lia Yuan.

## Research questions

- How does predicted policy stance differ between the Italian Parliament and Italy's UN speeches?
- Which themes characterize migration and military-related discourse in each setting?
- How do these patterns change over time and across parliamentary party families?
- Can generated summaries help contextualize the quantitative findings?

## Repository contents

| File | Purpose |
| --- | --- |
| [Data_preparation_nlp_final.ipynb](Data_preparation_nlp_final.ipynb) | Corpus loading, cleaning, language-specific sentence segmentation, keyword filtering, and parliamentary speech selection. |
| [nlp_project_BERT_classification.ipynb](nlp_project_BERT_classification.ipynb) | Manifesto training-data preparation, multilingual BERT fine-tuning, stance prediction, temporal comparisons, and human-label validation. |
| [nlp_project_LDA.ipynb](nlp_project_LDA.ipynb) | Four LDA analyses, topic selection, coherence and diversity evaluation, group comparisons, and optional manual validation. |
| [Translation_Summary_nlp_final.ipynb](Translation_Summary_nlp_final.ipynb) | Translation of parliamentary speeches and hierarchical summaries by topic, source, party family, and year. |
| [scripts/Manifesto_dataset_extraction_v1.2.R](scripts/Manifesto_dataset_extraction_v1.2.R) | Extraction of relevant annotated policy statements from the Manifesto Project data. |
| [reports/project_report_ID_06.pdf](reports/project_report_ID_06.pdf) | Research report with methodology, results, figures, and references. |
| [data/validation/all_labeled_samples.xlsx](data/validation/all_labeled_samples.xlsx) | Original 100-observation BERT validation sample with predictions and human labels. |
| [DATA_SOURCES.md](DATA_SOURCES.md) | Data provenance, required inputs, and generated intermediate files. |
| [PUBLICATION_NOTES.md](PUBLICATION_NOTES.md) | Corrections, validation performed, and remaining reproducibility limitations. |

## Approach

### 1. Data preparation

The parliamentary corpus comes from **ItaParlCorpus**, covering speeches in the Italian Chamber of Deputies. Italy's **UN General Debate** speeches provide the international comparison and are analyzed in English.

Texts are lightly cleaned and segmented using the appropriate spaCy language model. Migration and military-related sentences are identified using domain-specific keyword lists. Up to 100 unique parliamentary speeches are selected per year and party family, ranked by the strongest keyword-matching sentence. The selected rows retain both the matching sentence and full speech text.

The BERT and parliamentary LDA notebooks analyze the selected sentence-level excerpts; translation and summarization use full speech text. UN topic modeling uses filtered sentences. The optional semantic-retrieval experiment is retained for reference and disabled by default.

### 2. Policy-stance classification

The classifier fine-tunes [`google-bert/bert-base-multilingual-cased`](https://huggingface.co/google-bert/bert-base-multilingual-cased) on **5,000 Manifesto Project quasi-sentences**, with an 80/20 train/development split stratified by language and label.

Manifesto policy codes are mapped to task-specific positive and negative labels. These labels represent policy direction under the project's coding scheme, rather than general emotional sentiment. For example, the Peace category is mapped to the negative side of the military-policy framing. Results should be interpreted in light of this label design and the difference between manifestos and speeches.

### 3. Topic modeling

Separate Gensim LDA models are fitted for each source–policy combination. Preprocessing includes lemmatization, stopword removal, bigram construction, and dictionary filtering. Topic selection considers c_v coherence and interpretability. Evaluation includes top-word diversity and human–model top-k topic agreement.

### 4. Translation and summarization

Parliamentary speeches are translated using [`Helsinki-NLP/opus-mt-it-en`](https://huggingface.co/Helsinki-NLP/opus-mt-it-en). Long texts are split before translation to respect the model's input limit.

[`facebook/bart-large-cnn`](https://huggingface.co/facebook/bart-large-cnn) generates summaries through successive reductions: text chunks, individual speeches, and groups defined by policy area, source, party family, and year. UN speeches are grouped without a partisan distinction.

## Results from the original experiments

The original BERT run achieved approximately **0.81 macro-F1** on the development set. An independent annotator agreed with **72 of 100** sampled downstream predictions; this is a small single-annotator validation exercise.

| Corpus | Negative predictions | Positive predictions |
| --- | ---: | ---: |
| Migration — Parliament | 53.8% | 46.2% |
| Military — Parliament | 69.2% | 30.8% |
| Migration — UN | 28.1% | 71.9% |
| Military — UN | 39.7% | 60.3% |

Parliamentary discourse received a greater share of negative policy-stance predictions, while UN discourse received a greater share of positive predictions. Topic modeling provided context for these differences, including domestic legislation and political contestation in Parliament and international cooperation and humanitarian issues at the UN. These are descriptive, model-based findings; institutional, linguistic, and domain differences may all contribute.

The corrected report tables correspond to these original LDA outputs:

| Corpus | Topics | c_v coherence | Topic diversity |
| --- | ---: | ---: | ---: |
| Migration — Parliament | 7 | 0.405 | 0.881 |
| Military — Parliament | 5 | 0.454 | 0.833 |
| Migration — UN | 4 | 0.420 | 0.813 |
| Military — UN | 4 | 0.457 | 0.667 |

The report records the original experiments. The publication notebooks contain execution repairs and cleared outputs; the complete pipeline has not been rerun after these repairs, so the tables above are not new benchmark results.

## Running the project

### Environment

Use a Python 3.11 environment with Jupyter, or a Colab runtime configured with equivalent dependencies. Run notebooks with the **repository root as the working directory**, or set `NLP_PROJECT_ROOT` to its absolute path before running the configuration cell.

```bash
python -m venv .venv
# Activate the environment using the command appropriate for your operating system.
python -m pip install -r requirements.txt
python -m spacy download it_core_news_sm
python -m spacy download en_core_web_sm
jupyter lab
```

The requirements provide a starting environment with compatible version constraints; a fully executed environment lockfile is not supplied. A GPU is strongly advisable for BERT training, translation, and summarization. Model downloads require internet access.

For optional Manifesto extraction, install the R packages `dplyr`, `readxl`, and `openxlsx`, place the source files in `data/raw/`, and run from the repository root:

```bash
Rscript scripts/Manifesto_dataset_extraction_v1.2.R
```

### Data and execution order

1. Obtain the raw inputs described in [DATA_SOURCES.md](DATA_SOURCES.md). The large parliamentary corpus and Manifesto training extract are external inputs.
2. Run `Data_preparation_nlp_final.ipynb` to generate the four topic-specific input files in `data/processed/`.
3. Run `nlp_project_BERT_classification.ipynb` for classification. Either fine-tune from the supplied training-data format or load the complete saved fine-tuned model as explained in the notebook.
4. Run `nlp_project_LDA.ipynb` for topic modeling. This branch does not require BERT predictions. Manual validation requires four additional completed annotation workbooks and is disabled by default.
5. Run `Translation_Summary_nlp_final.ipynb` for the translation and summarization branch, which also starts from the data-preparation outputs.

The path configuration cell in every notebook separates raw inputs, processed data, validation files, model weights, and generated outputs. Drive mounts and personal Google Drive links are not required.

## Fine-tuned model

The trained BERT weights are **not bundled** with this repository. They can be distributed separately through a Hugging Face model repository; no public checkpoint URL is currently supplied.

For local inference, place the complete saved model directory at:

`models/final_bert_model3_balanced_data/`

Include the model weights, `config.json`, all tokenizer files saved by `tokenizer.save_pretrained`, and `best_threshold.json`. Follow the inference-only instructions in the BERT notebook. The original base BERT checkpoint alone does not reproduce the fine-tuned classifier.

See [models/README.md](models/README.md) for packaging details. Model weights, training checkpoints, raw data, and generated intermediate files are excluded from ordinary commits through `.gitignore`.

## Limitations

- The fine-tuning data differs from the downstream speeches in genre and institutional context.
- Italian and negative training examples are less numerous than English and positive examples.
- Keyword filtering may retain ambiguous passages and miss relevant texts without the chosen keywords.
- UN coverage is limited, and the corpora use different languages and document units.
- Human validation uses small samples and a single annotator.
- Hierarchical summarization may lose minority positions and discourse structure. No gold-standard summary evaluation is available.
- Raw corpora, completed LDA annotation workbooks, and trained weights are not bundled; full reproduction requires those inputs and a new execution.

Data sources and pretrained models retain their respective attribution and reuse conditions. See the report for the full bibliography.
