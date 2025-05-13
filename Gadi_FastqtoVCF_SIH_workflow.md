# Fastq-to-VCF Whole Genome Pipeline (Benchmarking on Gadi vs Artemis HPC)

This pipeline is adapted from the [Sydney Informatics Hub](https://github.com/Sydney-Informatics-Hub/Fastq-to-VCF) and benchmarks human whole genome analysis on **two different HPC systems**: **Gadi** and **Artemis**. It is part of YC's research project.

---

## 🧬 Configuration File Structure

The sample configuration file contains the following columns:

| Column        | Description                                                                 |
|---------------|-----------------------------------------------------------------------------|
| `SampleID`    | Unique identifier for the sample. Prefix for all related fastq files.       |
| `LabSampleID` | Desired ID used in final outputs (e.g., BAM, VCF). Must be unique.           |
| `Seq_centre`  | Sequencing center (e.g., MicroGen). No whitespace allowed.                  |
| `Lib`         | Library ID. Can be left blank; defaults to '1'.                             |

**Example Configuration:**


| SampleID | LabSampleID | Seq_centre | Lib |
| --- | --- |
| ASX1 | ASX1 | MicroGen | 1 |
| BCV1 | BCV1 | MicroGen | 1 |
| BQE1 | BQE1 | MicroGen | 1 |
| BVX1 | BVX1 | MicroGen | 1 |
| CPN1 | CPN1 | MicroGen | 1 |
| CUX1 | CUX1 | MicroGen | 1 |
| CWX1 | CWX1 | MicroGen | 1 |
| DQK2 | DQK2 | MicroGen | 1 |
| DUO1 | DUO1 | MicroGen | 1 |
| DUV1 | DUV1 | MicroGen | 1 |
| DXO1 | DXO1 | MicroGen | 1 |

---

## 🔁 Workflow Steps

### 1. Reference Genome Indexing

- **Reference**: GRCh38 (GCF_000001405.26, Dec 2013)
- **Used by**: Both Gadi and Artemis workflows

Command uses `bwa index` or equivalent. Sample metrics:
- Genome length: `6434693834`
- Memory used: ~81 GB
- NCPUs: 6
- Runtime: ~1.5 hours on Gadi

---

### 2. FastQC (Per-Sample Quality Check)

**Command**: `fastqc -t 1 *.fastq.gz`

- 22 FASTQ files (paired-end for 11 samples)
- Initial run failed due to insufficient walltime
- Each FastQC takes ~20–25 min per sample pair (with 1 thread)
- Recommended: 8 NCPUs, 32 GB memory, ≥ 3 hours walltime

---

### 3. MultiQC (Summary Report)

**PBS Script**: `bash Scripts/multiqc_fastqc.pbs`

- Module: `multiqc/1.9`  
- Scans FastQC outputs and generates `multiqc_report.html`  
- Outputs stored in `MultiQC/FastQC/`

```bash
[INFO] multiqc : Found 44 reports
[INFO] multiqc : Report : multiqc_report.html

4.	Split FastQ check
This step ensures R1/R2 files per each sample have equal number of reads, that the splitting process has not introduced any errors.

5.	Sequence alignment
Alignment is performed with bwa-mem2. The K value is applied to ensure thread count does not affect alignment output due to random seeding.
