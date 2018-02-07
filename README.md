shepherdlabephys
================

Table of Contents
-----------------

1. Introduction
2. Repository Structure
3. Usage

Introduction
------------

This is a repository for basic analysis of electrophysiology (mostly patch-
clamp) data in Matlab. It is maintained by John Barrett and is a mixture of new 
code and heavily refactored versions of older code written by other members of 
the Shepherd Lab, including but not limited to Gordon Shepherd, Naoki Yamawaki,
and Karl Guo.

It started as an attempt to unify the analysis code used in the lab, with the 
goal of making it general purpose, useable, maintainable, and easy to use. At 
present, it only works with Ephus and WaveSurfer data, but effort has been made
to separate actual analysis from I/O as much as possible, so it could (with a 
little extra effort) be used with any ephys software that outputs data in a 
Matlab-readable format.  

This repository is very much in its early stages and is intended as a constantly
evolving project. As such, it should not be considered stable and APIs may 
change at any time. Nevertheless, I will try not to make any breaking changes to
functions unless absolutely necessary.

Repository Structure
--------------------

This repository is designed to be as self-contained as possible, with no
external dependencies that I know of and minimal use of Matlab toolboxes.  If 
you running into undefined function errors while using this library, let me 
know as it's probably something I've either written and forgotten to move into
this repository or third-party code (usually from File Exchange) that should be
listed as a dependency.

### analysis

This is the meat of repository, containing functions for standard ephys
analyses, such as calculating intrinsic electrical properties of a cell from
voltage steps or calculating the temporal parameters of a response.  It also
contains functions for preprocessing data in various ways, e.g. by filtering or
averaging.

#### +mapAnalysis

The version in master is mostly complete but not guaranteed stable or correct 
reimplementation of the old mapAnalysis GUI used in the Shepherd Lab for
analysing (s)CRACM data. Eventually this will be generalised to support any 
dataset that comprises a 'map' of time series data: for a preview of this, see
the feature-motormapping branch (warning: currently under developmenet, may be
broken).

### backwards compatibility

This folder is for functions to work around differences between different 
versions of Matlab, such as the function addParameter, which this repository 
makes heavy use of but was only introduced in Matlab 2013b.

### data wrangling

Functions for loading data into Matlab and coercing it into the format 
expected by other functions in the library. At present only WaveSurfer HDF5 
and Ephus xsg files are supported.

### example scripts

Examples of how to use the functions contained in this repository for various
analyses, plus the older scripts that this repository replaces.

### plotting

Functions to plot ephys data in consistent ways. Not intended to replace the
default Matlab plotting functions, but provide a little wrapper around them for
certain very common types of plots without writing a bunch of code that looks
the same.

### utils

Utility functions that are used by other functions in the repository but don't
really belong anywhere else.

Usage
-----

Detailed documentation for each function in this repository is (or should be
- let me know if you find any missing) included with each function. Just type
`help <function name>` or `doc <function name>` at the Matlab commmand window
for info. Hence this section will not describe usage for every function. 
Instead, this is just a brief overview of the repostiory and how to use it.

### Writing Scripts

The general process for analysing data with this Matlab repository is as 
follows:

1. Load data using the data wrangling functions
2. Analyse data using the analysis functions
  * Usually you'll want to start with some combination of `preprocess` and/or
   `splitData`.
3. Plot the data using the plotting functions

If you find yourself writing similar code over and over again or write some
analysis that you think will be useful to the general Ephus/WaveSurfer 
community, feel free to wrap it in a function and submit it as a pull request.

### BasicEphysAnalysisGUI

This started out as a usage demo for this repostiory, but some members of our
lab with less programming experience found it useful for actually analysing 
data, so I kept adding features until it turned into something semi-functional
and handy for basic, first-pass ephys analysis.

#### Loading and selecting data

Load Ephys or WaveSurfer data using the Choose Files... button. You can load
as many files containing as many traces as you want, but at present all traces
in every file are loaded into memory, so for very large datasets (especially
from WaveSurfer) this may take a while and at present there's no spinner, so if
it looks like it's not doing anything, just be patient.

After loading, to select a subset of the traces, use the Choose Traces... 
button. You can select individual traces, all traces from individual sweeps
(e.g. if you're doing multichannel acquisition, each sweep will comprise one
trace per channel), or all traces for individual channels. For any of those
options, if there are more than about 10 choices, you'll only be able to select
a range using two slider bars. This may change in future versions.

#### Previewing data

The drop-down menu at the top allows you do see the raw data, various processed
versions of the data, or any of the calculated parameters.  The data is 
displayed in the main figure.

#### Analysing data

Please note that all analyses are recalculated every time you load data, select
data, or change any of the parameters.

BasicEphysAnalysis provides basic data preprocessing and two main analyses: 
intrinsic cell parameters (such as series resistance, membrane capacitance),
and parameters of responses to some stimulus (e.g. peak, latency). The latter
makes few assumptions about the shape of the response, except that it is mono-
phasic, happens after the stimulus, and can be in either direction. Calculating
response parameters also calculates the charge transferred, but the values will
make no sense if the data was not recorded in current clamp mode or the cell
parameters have not been calculated appropriately.

1. Preprocessing:
   1.1 The baseline subtract button calculates the average of the raw traces
       over the specified window and subtracts it from the data.
   1.2 The filtering options allow you to perform a median or mean filter of
       the specified length before or after averaging (or both). If baseline
       subtract is checked, filtering will be performed on the baseline
       subtracted data, otherwise the raw data.
2. Calculating cell intrinsic parameters:
   2.1 The 'Using:' drop-down allows you to pick which set of traces to use for
       calculating cell parameters.
   2.2 The calculation assumes you perform a small voltage step of the specified
       magnitude and direction. Note that the values in **volts***, so e.g. a 
       5mv negative voltage step would be expressed as -0.005.
   2.3 The calculation has two windows, one for the response (i.e. when you 
       applied the voltage step) and one for the steady-state (after the
       initial transient when the input current has settled down to its new
       value).  Note that the starts of **both** windows are from the beginning
       of the trace, i.e. the steady-state start is not relative to the response
       start.
3. Calculating temporal parameters:
   3.1 As for cell parameters, you can select which traces to calculate temporal
       parameters from.
   3.2 The Start is when relative to the start of the trace you applied the
       stimulus, not where you expect the response to start.
   3.3 The Length is the length over which you want to look for responses. If 
       unsure, just set it to the sweep length minus the start value.
4 Changing the recording mode:
   4.1 This just changes the Y-axis label between millivolts (for IC mode) and
       picoamperes (for VC mode) on the trace viewer. No change is made to the 
       underlying data nor the method of calculation.

#### Exporting data

Pressing the Save Data... button allows you to save all of the calculated values
for the currently selected traces as a .mat file. The variable names in the file
should be fairly self-explanatory. Pressing the Save Figure... button creates a
copy of the preview window in a new figure window, which you can then save.

### mapalyzer

Under construction. Probably best not to use it yet, unless you're familiar with
the old mapAnalysis script, in which case use with caution.