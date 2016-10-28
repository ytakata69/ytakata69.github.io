#!/bin/sh

infile=$1
outfile=`basename ${infile} .eps`.svg
automator -i ${infile} image2pdf.workflow
pdf2svg $HOME/Desktop/NewPDFfromImage.pdf ${outfile}
