# Two Narratives: Comparing Domestic and International Framing of Political Speeches

An NLP research project comparing how Italy discusses **migration** and **military and defense policy** in domestic parliamentary debates and international UN speeches between **2006 and 2022**.

The project combines multilingual BERT classification, LDA topic modeling, Italian-to-English translation, and hierarchical summarization to examine differences across institutional settings, political groups, and time.

**Authors:** Milana Arsenteva, Anna Ciapparelli, Sara Pulidori, and Lia Yuan.

## My Contribution

I was responsible for the complete BERT classification component, including preparing the supervised fine-tuning dataset, fine-tuning multilingual BERT, evaluating model performance, and applying the classifier to parliamentary and UN speeches.

I also analyzed differences in predicted policy stance across datasets and time periods and compared model predictions with human annotations.

Beyond the classification component, I contributed to the background research, interpretation of the findings, and writing of the final project report.

## Research questions

- How does predicted policy stance differ between the Italian Parliament and Italy's UN speeches?
- Which themes characterize migration and military-related discourse in each setting?
- How do these patterns change over time and across parliamentary party families?
- Can generated summaries help contextualize the quantitative findings?

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

Data sources and pretrained models retain their respective attribution and reuse conditions. See the report for the full bibliography.
