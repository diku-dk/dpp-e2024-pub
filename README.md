# Data Parallel Programming (DPP), Block 2 2024

## Course Structure

<img align="right" width="300" src="https://github.com/user-attachments/assets/d377dc77-3495-4b40-9464-d314b0fee8e2">

DPP is structured around five weeks with lectures and lab sessions
on Monday and Wednesday, followed by a final project to be
presented orally at the exam.  Throughout the course, you will hand in
four weekly assignments.  These *weeklies* count for 40\% of the
grade, while the exam counts for 60\%.

The teachers are **Cosmin Oancea** and **Troels Henriksen**.

All lectures and lab sessions will be delivered in English. The
assignments and projects will be posted in English, and while you can
chose to hand in solutions in either English or Danish, English is
preferred.

All course material is distributed via this GitHub page.  Assignment
handin is still on Absalon.  There is no mandated textbook for the
course - you will be assigned reading material from papers and such.

## Course schedule

[Course Catalog Web Page](https://kurser.ku.dk/course/ndak21006u/2024-2025)

[Official schedule](https://skema.ku.dk/tt/tt.asp?SDB=ku2425&language=EN&folder=Reporting&style=textspreadsheet&type=student+set&idtype=id&id=211506&weeks=1-53&days=1-7&periods=1-68&width=0&height=0&template=SWSCUST+student+set+textspreadsheet)

### Lectures (zoom links will be posted on Absalon):

* Monday    13:00 - 15:00 in Lille UP-1 at DIKU
* Wednesday 10:00 - 12:00 in Lille UP-1 at DIKU

<img align="left" width="300" src="https://github.com/user-attachments/assets/31e64447-eb76-4749-928c-5be09bf37bd2">

### Labs:

* Monday 15:00 - 17:00 in 3-0-25 at DIKU.
* Wednesday 13:00 - 15:00 in Lille UP-1 at DIKU.


This course schedule is tentative and will be updated as we go along.
**The schedule below will become the correct one as you enter the
week when the course starts.**

The lab sessions are aimed at providing help for the weeklies and
group project.  Do not assume you can solve them without showing
up to the lab sessions.

### Lecture plan

TBA

## Weekly assignments

<img align="right" width="300" src="https://github.com/user-attachments/assets/720668fd-cde1-4000-8729-72771f5b09b9">

The weekly assignments are **mandatory**, must be solved
**individually**, and make up 40% of your final grade.  Submission is
on Absalon.

The assignment text and handouts will be linked in the schedule above.

#### Feedback and resubmission

[Your TA, Anders](#TA), will be grading and providing feedback on your
weekly assignments. You receive feedback within a week of the handin
deadline, and one resubmission attempt is granted for each weekly
assignment, which may be used to solve tasks missing in the original
hand-in and/or to improve on the existing hand-in (but note that
feedback may be sparse for resubmissions).

As a rule of thumb, the resubmission deadline is **two weeks from the
original handin deadline**, but it is *negotiable*.

Extensions may be granted on weekly assignment (re-)submission
deadlines -- please ask [Anders](#TA) if for any reason, personal or
otherwise, you need an extension (no need to involve Cosmin or Troels
unless you wish to complain about Anders' decision).

## Group project and exam

The final project, along with the exam as a whole, contributes 60% of
your grade, and is done in groups of 1-3 people (although working
alone is strongly discouraged). We have [a tenative list of project
suggestions](project-suggestions.md), but you are free to suggest your
own (but please talk with us first). Since the time to work on the
project is rather limited, and there is no possibility of
resubmission, you should ask for help early and often if you are
having trouble making progress. **The project should be handed in via
Absalon in TBA**. Send an email if you have trouble meeting this
deadline.

Most of the projects are about writing some parallel program, along
with a report describing the main points and challenges of the
problem.  The exam format is a group presentation followed by
individual questions about both your project **and anything else in
the curriculum**.  Each group prepares a common presentation with
slides, and each member of the group presents non-overlapping parts of
the presentation for about 10 min (or less). Then each member of the
group will answer individual questions for about 10 min.

## Practical information

### TA
Your TA is **Anders Holst**
([lietzen@di.ku.dk](mailto:lietzen@di.ku.dk), Discord: `sortraev`).
Anders will be grading your weekly assignments and patrolling the
online discussion forum(s) (with help from Troels).

### Discussion forum(s) + course Discord link

We provide a Discord channel for discussions, invite here:
[discord.gg/2wPBbAYT9G](https://discord.gg/2wPBbAYT9G) (please contact
Anders should the link expire), and advice that you join as soon as
possible.

We encourage active discussion of course subjects with fellow
students, so long as you refrain from directly discussing or sharing
solutions to weekly assignments and the exam/group project. Should you
have questions pertaining to your particular solution, please ask them
in a private message to Anders (your TA), who may refer you to Troels.

Please note that while we prefer Discord for communication, you are
free to use the Absalon discussion forum and private messaging system,
and that no announcement shall be posted to Discord which has not
already been posted to Absalon.

### Hendrix GPU cluster

You may find it useful to make use of DIKUs GPU machines in your work.
We recommend using the so-called [Hendrix
cluster](https://diku-dk.github.io/wiki/slurm-cluster#getting-access).
If you are enrolled in the course, you should already have access.
Otherwise contact Troels at <athas@sigkill.dk>. For how to access
Hendrix, follow the first link in this paragraph.

Consider using
[sshfs](https://www.digitalocean.com/community/tutorials/how-to-use-sshfs-to-mount-remote-file-systems-over-ssh)
to mount the remote file system on your local machine:

```
$ mkdir remote
$ sshfs hendrix:/ remote
```

[Also see here for more
hints.](https://github.com/diku-dk/howto/blob/main/servers.md#the-hendrix-cluster)

#### Using Hendrix

The DIKU systems have a [conventional HPC modules
setup](https://hpc-wiki.info/hpc/Modules), meaning you can make
additional software available with the ``module`` command. You may
need to do this inside SLURM jobs.

##### Loading CUDA

```bash
$ module load cuda
```

##### Loading Futhark

```bash
$ module load futhark
```

##### Loading ISPC

```bash
$ module load ispc
```

(Although there is no reason to use Hendrix for ISPC - it will run
fine on your machine.)

## Other resources

You are not expected to read/watch the following unless otherwise
noted, but they contain useful and interesting background information.

* [The Futhark User's Guide](https://futhark.readthedocs.io), in
  particular [Futhark Compared to Other Functional
  Languages](https://futhark.readthedocs.io/en/latest/versus-other-languages.html)

* [Troels' PhD thesis on the Futhark compiler](https://futhark-lang.org/publications/troels-henriksen-phd-thesis.pdf)

* [A library of parallel algorithms in NESL](http://www.cs.cmu.edu/~scandal/nesl/algorithms.html)

* [Functional Parallel Algorithms by Guy Blelloch](https://vimeo.com/showcase/1468571/video/16541324)

* ["Performance Matters" by Emery Berger](https://www.youtube.com/watch?v=r-TLSBdHe1A)

* [The story of `ispc`](https://pharr.org/matt/blog/2018/04/18/ispc-origins.html) (you can skip the stuff about office politics, although it might ultimately be the most valuable part of the story)

* [Scientific Benchmarking of Parallel Computing
  Systems](https://htor.inf.ethz.ch/publications/img/hoefler-scientific-benchmarking.pdf)
  (we benchmark much simpler systems and don't expect anywhere near
  this much detail, but it's useful to have thought about it)

## Acknowledgements

NVIDIA has donated GPUs used for teaching DPP for several years.

Thanks to Filippa Biil for the hedgehogs.
