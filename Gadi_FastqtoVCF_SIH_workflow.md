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

```
SampleID	LabSampleID	Seq_centre	Lib
ASX1	ASX1	MicroGen	1
BCV1	BCV1	MicroGen	1
BQE1	BQE1	MicroGen	1
BVX1	BVX1	MicroGen	1
CPN1	CPN1	MicroGen	1
CUX1	CUX1	MicroGen	1
CWX1	CWX1	MicroGen	1
DQK2	DQK2	MicroGen	1
DUO1	DUO1	MicroGen	1
DUV1	DUV1	MicroGen	1
DXO1	DXO1	MicroGen	1
![image](https://github.com/user-attachments/assets/cc6ead4f-83ed-4dc0-8d4e-8375b029bc46)

```

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
```

---

### 4. Splitting FASTQ Files (for Parallel Processing)

**Tool**: `fastp v0.20.0`

- Splits paired-end reads for optimized HPC use
- Target: 10 million paired-end reads per file
- Split file size: **40 million lines** (based on SIH recommendation)
- Each task (~12 CPUs) needs ~40 GB RAM and ~15 min on Gadi

---

### 5. Split FastQ Check

Checks integrity of splitting:
- Ensures paired files (R1/R2) have equal read counts
- Validates no errors introduced during splitting

---

### 6. Sequence Alignment

**Tool**: `bwa-mem2`

- `-K` option ensures deterministic output regardless of thread count
- Output format: `.bam` files
- Proper resource allocation (memory, threads) is critical

---

## 💡 HPC Resource Sample (Gadi)

| Resource       | Value             |
|----------------|------------------|
| Walltime       | 01:26:52          |
| CPUs Used      | 6                 |
| Memory Used    | 81.1 GB (out of 192 GB) |
| Project ID     | `ut47`           |
| SU Consumption | 26.06 SU          |

---

## 🔁 To Do Next

- Add GATK/DeepVariant variant calling steps
- Add downstream filtering and annotation
- Create `.pbs` scripts for each step

---

## 📌 Notes

- This workflow currently benchmarks differences between Artemis and Gadi for WGS.
- Ensure module versions match across systems for reproducibility.
- Consider containerizing the pipeline using Singularity or Docker for portability.

---
