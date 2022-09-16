# codimThreeCode
## Project Overview
This code is dedicated to classifying Differential-Graded (DG) Algebra ring structures on free resolutions of perfect ideals in the trivariate polynomial ring over a (finite) field.  
## M2 Language
The project is implemented in the Macaulay2 programming language, which is an interpreted, functional programming language dedicated to the analysis of mathematical objects.  More information about the [Macaulay2 Language can be found here](http://www2.macaulay2.com/Macaulay2/)
## How to use this repository
### Step 1
Install Macaulay2.  Follow the documentation found at the link above.  Windows users may need to install *WSL*.
### Step 2
Fetch needed files.  One can clone the repository via git:
`git clone https://github.com/ogotchey/codimThreeCode/`
Alternatively, one can download a given file manually from the repository.
All of the generator data is stored in the directory named `data`.  A given .txt file in that directory has filename of the form:
`m-n-CLASS-p-q-r`, according to these invariants of the ring.   This choice of variable name is relatively standard in the literature, as one could find for example in [^1]
### Step 3
Import a class into Macaulay2.  In a fresh instance of Macaulay2:
`needsPackage TorAlgebra`
`fileIn = lines get "6-4-H-0-0-0.txt"`
You will see a list of matrices, each one representing a set of generator for the given class:
> o9 = matrix {{x*z^2, y^2*z, x^2*y, x^3, z^4, y^4}}
     matrix {{z^3, x*z^2, y^3, x*y^2, x^2*y, x^3-y*z^2}}
     matrix {{z^3, x^2*z, y^3, x*y^2, x^2*y-x*z^2+y*z^2, x^3-y^2*z}}
     matrix {{z^3, y^2*z, x^2*z+x*y*z-x*z^2+y*z^2, x*y^2+y^3, x^2*y, x^3}}
     matrix {{y*z^2, y^2*z+x*z^2, y^3+x^2*z-x*y*z, x*y^2-x^2*z+x*y*z+z^3, x^2*y-x*y*z, x^3-z^3}}
     matrix {{x*z^2, x*y*z+y^2*z-y*z^2, y^3+x^2*z, x*y^2-x^2*z+y^2*z, x^2*y+x^2*z-z^3, x^3-x^2*z-z^3}}
     matrix {{y^2*z, x*y*z-x*z^2, y^3+x*z^2-y*z^2-z^3, x*y^2+x*z^2+z^3, x^2*y+x*z^2-y*z^2-z^3, x^3-x^2*z}}
     matrix {{x*z^2-y*z^2-z^3, x*y*z+y^2*z+y*z^2, x^2*z+z^3, x*y^2, x^2*y+y^3+y*z^2+z^3, x^3-y^3+y^2*z-y*z^2}}
     matrix {{x*y*z+x*z^2+z^3, x^2*z-y*z^2+z^3, y^3-y^2*z+x*z^2+z^3, x*y^2+x*z^2+y*z^2-z^3, x^2*y-y*z^2+z^3, x^3-x*z^2-y*z^2-z^3}}
     matrix {{x*y*z+y^2*z+y*z^2+z^3, x^2*z+x*z^2+z^3, y^3-y^2*z+x*z^2-z^3, x*y^2-y^2*z+y*z^2-z^3, x^2*y+x*z^2+y*z^2+z^3, x^3-y^2*z+x*z^2}}
     matrix {{x*y*z+y*z^2-z^3, x^2*z-y^2*z-x*z^2+y*z^2+z^3, y^3+x*z^2-y*z^2+z^3, x*y^2+y*z^2+z^3, x^2*y-y^2*z+x*z^2+y*z^2+z^3, x^3+y^2*z-x*z^2+y*z^2}