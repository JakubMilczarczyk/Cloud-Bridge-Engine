# ADR 003: Pivot on AMD Micro instance and Oracle Linux 8

**Date:** 2026-06-16
**Status:** Accepted

## Context
In line with our initial financial assumptions (FinOps - Always Free), we planned to deploy an ARM-based server (Ampere A1) running Ubuntu 22.04. During the provisioning phase (Terraform), we encountered two critical blockers on the provider side (Oracle Cloud - Frankfurt region):
1. A widespread lack of physical resources for ARM instances ("Out of host capacity").
2. Authorization blocks (IAM / Policy Restrictions) when attempting to run Canonical Ubuntu images on smaller, free instances with AMD processors.

## Decision
We decided on an immediate architectural pivot:
1. Changing the server form factor from ARM to VM.Standard.E2.1.Micro (x86_64, AMD).
2. Changing the operating system from Canonical Ubuntu to the vendor's native operating system: **Oracle Linux 8**, which has guaranteed resource allocation on free accounts.
3. Due to the 1 GB RAM limitation on Micro instances, the decision was made to create 4 GB of swap memory on the block disk to secure the Docker processes.

## Consequences
**Positive:** 
* Complete implementation success (IaC).
* Guaranteed freedom from permissions issues (cloud-native image).

**Negative:** 
* Reduced physical RAM requiring aggressive swap file management, which may minimally impact I/O performance.
* Changed the default SSH user from `ubuntu` to `opc`.