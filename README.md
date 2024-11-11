# Relational Database Courses with CodeRunner in Moodle: Extending SQL Programming Assignments to Client-Server Database Engines

[![Conference Badge](https://img.shields.io/badge/conference-SIGCSE_2025-blue.svg)](https://sigcse2025.sigcse.org) [![DOI](https://img.shields.io/badge/DOI-10.1145%2F3641554.3701830-ff69b4.svg)](https://doi.org/10.1145/3641554.3701830)

**Authors:** [Andrzej Wójtowicz](https://awojt.pl), Maciej Prill

```
@inbook{10.1145/3641554.3701830,
    author = {Wójtowicz, Andrzej and Prill, Maciej},
    title = {Relational Database Courses with CodeRunner in Moodle: Extending SQL Programming Assignments to Client-Server Database Engines},
    year = {2025},
    isbn = {9798400705311},
    publisher = {Association for Computing Machinery},
    address = {New York, NY, USA},
    url = {https://doi.org/10.1145/3641554.3701830},
    doi = {10.1145/3641554.3701830},
    booktitle = {Proceedings of the 56th ACM Technical Symposium on Computer Science Education V. 1},
    pages = {1239–1245},
    numpages = {7},
    abstract = {Students practice Data Query, Manipulation, and Definition Language statements in a standard introductory relational database course. When teaching large classes, the teacher needs to review many student solutions. Doing it by hand is laborious. However, this task can be quickly and accurately completed using a learning management system (LMS). Moodle is a widely used LMS that can be enhanced with the CodeRunner plugin to facilitate the evaluation of programming tasks. Unfortunately, a basic setup supports only the embedded database engine SQLite, which often is not the preferred choice for a course of this type. We present an open-source implementation that extends CodeRunner with popular client-server database engines, i.e., Microsoft SQL Server, MySQL, and PostgreSQL. Our method checks the correctness of a student's query in terms of output and validates the query by investigating the parse tree derived from the grammar of a given Structured Query Language (SQL) dialect. We present the system's evaluation results during a database course along with the implementation.}
}
```

## Description

This repository contains the code accompanying the research paper presented at the SIGCSE conference in 2025. The paper is available in the [ACM Digital Library in Open Access](https://dl.acm.org/doi/10.1145/3641554.3701830).

## Servers config

LMS server:

* [Ubuntu Server](https://ubuntu.com) 24.04
* [Moodle](https://moodle.org/) 4.5
* [CodeRunner](https://coderunner.org.nz/) plugins:
  * [qbehaviour_adaptive_adapted_for_coderunner](https://moodle.org/plugins/qbehaviour_adaptive_adapted_for_coderunner) 1.4.4
  * [qtype_coderunner](https://moodle.org/plugins/qtype_coderunner) 5.5.0

Grading server:

* [Debian](https://www.debian.org) 12.9
* [Jobe](https://github.com/trampgeek/jobe) 2.1.1

## Repository

The repository is organized as follows:

- `mssql-shared/` - files and instructions for Microsoft SQL Server,
- `mysql-shared/` - files and instructions for MySQL,
- `postgresql-shared/` - files and instructions for PostgreSQL.

In each directory, there are the following files:

* `INSTALL.md` with instructions to run on the grading server,
* `requirements.txt` with Python pip modules,
* `*.xml` with question prototype and sample questions to import in Moodle course (it is best to familiarize yourself with sample questions by adding them directly to the quiz later),
* `README.md` with a description of the prototype (it is also available in Moodle question editor in the "Question type details" section).

## Demo

Watch the video on [YouTube](https://youtu.be/MsTHtExBcrk).

[![Watch the video](https://img.youtube.com/vi/MsTHtExBcrk/maxresdefault.jpg)](https://youtu.be/MsTHtExBcrk)
