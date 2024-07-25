# diaRamanPressure

Purpose of the code: Create a graphical interface to evaluate hydrostatic pressure based on the Raman signal of a diamond anvil

Copyright 2024 Idir Driche, Université de lille, France, under the supervision of Sébastien Merkel and Julien Chantel

This work is a part of ERC hotcores project that has received funding from the European Research Council (ERC) under the grant agreement No 101054994.
https://erc-hotcores.univ-lille.fr/

## How to run the code

The code is written in Octave. To run the code, you should 
 - install Octave from https://octave.org/ including *optim*, the non-linear optimization toolkit for Octave
 - open the source code
 - click on the green arrow

## How to use the code

The code is an automated version of what can be found at http://kantor.50webs.com/ruby.htm

To fit your pressure, simply
 - load your diamond Raman spectrum (in text format) by clicking on *Load Data*
 - apply smoothing by selecting the number of pixel to use for smooting data using a running average (7 is a good number)
 - click on *calculate the derivative of the smooth data*
 - select the region with the diamond edge on the right plot by cliking on the left and right sides of the negative peak
 - the position of the diamond peak edge will be automatically written in the *found value* box
 - enter the reference value for the diamond Raman peak (typically 1334 cm-1)
 - click on *Calcule pressure*

 ## Calibration

Calibration is from Yuichi Akahama and Haruki Kawamura (2006) Pressure calibration of diamond anvil Raman gauge to 310 GPa *J. Appl. Phys.*  100: 043516 https://doi.org/10.1063/1.2335683
