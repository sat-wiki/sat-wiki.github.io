---
title: "The 69-column layout of a TLE line"
date: 2026-11-12
categories: ["Orbits"]
tags: ["TLE", "orbital mechanics", "NORAD"]
series: ["TLE parsing"]
summary: "A column-by-column reading of the fixed-width TLE format: what each field means, where the decimal point is implied, and how the checksum is computed."
---

A two-line element set (TLE) is a fixed-width text format inherited from NORAD. Its constraint is not what the text means but **where each character sits**: every line is exactly 69 characters wide, field widths are fixed, decimal points are usually omitted, and one column is given over to a checksum. Parsers that fail usually drift by one column rather than miscompute a number.

## Fields on line 1

| Column | Width | Meaning |
|---|---|---|
| 1 | 1 | Line number, always `1` |
| 3 to 7 | 5 | Satellite number (NORAD catalogue number) |
| 8 | 1 | Classification: `U` unclassified, `C` classified, `S` secret |
| 10 to 11 | 2 | Last two digits of the international designator launch year |
| 12 to 14 | 3 | Launch number of that year |
| 15 to 17 | 3 | Piece of that launch |
| 19 to 20 | 2 | Last two digits of the epoch year |
| 21 to 32 | 12 | Epoch: day of the year plus its fractional part |
| 34 to 43 | 10 | First derivative of mean motion |
| 45 to 52 | 8 | Second derivative of mean motion |
| 54 to 61 | 8 | BSTAR drag term |
| 63 | 1 | Ephemeris type, normally `0` |
| 65 to 68 | 4 | Element set number, incremented on every update |
| 69 | 1 | Checksum |

Columns 2, 9, 18, 33, 44, 53, 62 and 64 hold spaces and nothing else. A parser that reads past them without accounting for them is off by one from that point onwards.

## Fields on line 2

| Column | Width | Meaning |
|---|---|---|
| 1 | 1 | Line number, always `2` |
| 3 to 7 | 5 | Satellite number, must match line 1 |
| 9 to 16 | 8 | Inclination, degrees |
| 18 to 25 | 8 | Right ascension of the ascending node, degrees |
| 27 to 33 | 7 | Eccentricity, **with the leading `0.` dropped**: `1234567` means 0.1234567 |
| 35 to 42 | 8 | Argument of perigee, degrees |
| 44 to 51 | 8 | Mean anomaly, degrees |
| 53 to 63 | 11 | Mean motion, revolutions per day |
| 64 to 68 | 5 | Revolution number at epoch |
| 69 | 1 | Checksum |

Two traps sit here. Eccentricity has to be read as a fraction, with `0.` put back before the digits. Mean motion is in **revolutions per day**, so converting to angular rate means multiplying by 360 degrees, and converting to a period means taking the reciprocal and rescaling to seconds.

The derivative and BSTAR fields use the same shorthand in a different form: ` 12345-4` stands for 0.12345 times ten to the minus four, with the mantissa's decimal point and the exponent letter both left out.

## The checksum

The checksum covers the first 68 characters. Digits count as their face value, a minus sign counts as one, a decimal point counts as one, everything else counts as zero. The total is taken modulo 10 and written into the last column.

A mismatch usually means the line was truncated or shifted in transmission, not that the orbit data itself is wrong.

## How the numbers get used

A TLE holds mean elements, so it cannot be used directly as an instantaneous set for high-precision extrapolation. For position prediction, a model such as SGP4 converts the mean elements into an osculating state, and the propagation time since epoch is added on top. The further the request sits from epoch, the faster the error grows, which shows up most sharply for low Earth orbit objects.

The [TLE analyzer](/tools/tle_data_analyzer.html) on this site cuts a line by column and prints each field, which makes it a convenient reference when checking a custom parser.
