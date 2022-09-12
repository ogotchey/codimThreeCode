-- Routines for exploring rings of codepth 3

newPackage ( "TorAlgebraTools",
    Version => "0.4",
    Date => "19 February 2018",
    Authors => {
	{ Name => "Lars Winther Christensen",
	  Email => "lars.w.christensen@ttu.edu",
	  HomePage => "http://www.math.ttu.edu/~lchriste/index.html" },
	{ Name => "Oana Veliche", 
	  Email => "o.veliche@neu.edu",
	  HomePage => "http://www.math.neu.edu/people/profile/oana-veliche/" }
	},
     Headline => "This is work in progress",
     PackageImports => {"LocalRings","LexIdeals","TorAlgebra"},
     Reload => true,
     DebuggingMode => true
     )

export { "hf", "hvector", "isCompressed", "hvectorCompressed",
    "torAlgFormat", "sup", "inf", "grade", "isPerfect", "zeroIdeal",
    "isZeroIdeal", "soc", "socdegs", "socdeg", "randomIdeal",
    "randomIdealFromDual", "monomialCount", "genericGenerator",
    "genericSequenceOfGenerators", "regularSequenceOfGenerators",
    "regularSequenceOfGeneratorsOfMinDeg", "genericElement",
    "genericSequenceOfElements", "regularSequenceOfElements",
    "genericLink", "genericLinkOfMinDeg", "degreeIdeal" }

    -- "bcghtFormat", "bcghtLN", "bcghtIsLN", "bcghtBetti", "bcghtBass", 
    -- "countFormat", "countFormatAndStore", "countClass", "countLinkFormat", "countLinkClass",
    -- , "isZeroIdeal",   
    -- , 
    -- "randomLink", "randomSubideal", "removeGenerator", "multiplyGenerator",
    -- "pinchGenerator", "BRLink", "BRLinkIdeal", "BRDoubleLinkIdeal" }

----------------------------------------------------------------------

zeroIdeal = R -> ideal (map(R^1,R^0,0))

isZeroIdeal = K -> (
    if K == zeroIdeal (ring K) then true else false
     )

soc = R -> (
    (zeroIdeal R):(ideal vars R)
    )

socdegs = R -> (
    flatten degrees soc R
    )

socdeg = R -> (
    last socdegs R
    )

----------------------------------------------------------------------

torAlgFormat = method();

torAlgFormat (Ring) := R -> (
    torAlgFormat ideal R
    )

torAlgFormat (Ideal) := I -> (
    if isHomogeneous I then (
	F := res I;
	)
    else (
	setMaxIdeal ideal vars ring I;
	I = ideal localMingens (localResolution I).dd_1;
	F = localResolution I;
	);
    L := {};
    i := 0;
    while rank F_i != 0 do (
	L = append(L, rank F_i);
	i = i+1;
	);
    L )
    
----------------------------------------------------------------------

hf = (e,i) -> (
    if i < 0 then b := 0 else b = binomial(i+e-1,e-1);
    b )

hvector = method();

hvector (Ring) := R -> (
    if codim R < numgens ideal vars R then L := {infinity} else (
    	L = {};
	i := 0;
	while hilbertFunction(i,R) != 0 do (
	    L = append( L, hilbertFunction(i,R) );
	    i = i+1;
	    )
	);
    L )

hvector (Ideal) := I -> (
    R := (ring I)/I;
    hvector R
    )    

hvectorCompressed = method();

hvectorCompressed (ZZ, List) := (e,S) -> (
    for i from 0 to max S list min(hf(e,i),sum for s in S list hf(e,s-i))
)

hvectorCompressed (List) := S -> (
    hvectorCompressed(3,S)
)

isCompressed = method();

isCompressed (Ideal) := I -> (
    Q := ring I;
    R := Q/I;
    if soc R == zeroIdeal R then ( flag := false ) else (
	S := socdegs R;
	flag = true;
	for i from 0 to last S do (
	    if hilbertFunction(i,R) != min(hilbertFunction(i,Q), 
	    sum (for s in S list hilbertFunction(s-i,Q))) then (
		flag = false;
	       	break;
		);
	    );
	);
    flag )
    
isCompressed (Ring) := R -> (
    I := ideal R;
    isCompressed I
    )

----------------------------------------------------------------------
    
-- sup
--
-- C a chain complex
--
-- Returns the supremum of C: the highest degree of a non-zero module

sup = C -> (
    j := max C;
    while true do (
        if j < min C then (
	    break -infinity 
	    )
	else (
	    if C_j != 0 then (
		break j 
		)
	    else (
		j = j-1
		)
	    )
	)
    )

inf = C -> (
    j := min C;
    while true do (
        if j > max C then (
	    break infinity 
	    )
	else (
	    if C_j != 0 then (
		break j 
		)
	    else (
		j = j+1
		)
	    )
	)
    )

grade = I -> (
    if isHomogeneous I then (
	F := res I;
	)
    else (
	setMaxIdeal ideal vars ring I;
	I = ideal localMingens (localResolution I).dd_1;
	F = localResolution I;
	);
    - sup chainComplex prune HH(dual F)
    )

isPerfect = I -> (
    if isHomogeneous I then (
	F := res I;
	)
    else (
	setMaxIdeal ideal vars ring I;
	I = ideal localMingens (localResolution I).dd_1;
	F = localResolution I;
	);
     H := chainComplex prune HH(dual F);
     if sup H == inf H then true else false
     )

---------------------------------------------------------------------- 

genericGenerator = (K,d) -> (
     B := 0; 
     for j from 0 to ( numgens K - 1 ) do ( 
	  if (degree K_j)#0 == d then B = B + random(0,ring K)*K_j;
	  );
     B )

genericSequenceOfGenerators = method();

genericSequenceOfGenerators (Ideal,List) := (K,D) -> (
    X := ideal ();
    for i from 1 to #D do (
	while numgens X < i do (
	    X = X + ideal genericGenerator(K,D#(i-1));
	    );
	);
    X )

genericSequenceOfGenerators (Ideal,ZZ) := (K,l) -> (
     F := flatten degrees K;
     D := {};
     for i from 1 to l do (
     	  F = random F;
    	  D = append(D,first F);
	  F = drop(F,1);
     	  );
     genericSequenceOfGenerators(K,D) )

----------------------------------------------------------------------

genericElement = (K,d) -> (
     B := 0; 
     for j from 0 to ( numgens K - 1 ) do ( 
	 k := (degree K_j)#0;
	 if k <= d then (
	     B = B + random(d-k,ring K)*K_j;
	     );
	 );
     B )
 
genericSequenceOfElements = method();
 
genericSequenceOfElements (Ideal,List) := (K,D) -> (
    X := ideal ();
    for i from 1 to #D do (
	while numgens X < i do (
	    X = X + ideal genericElement(K,D#(i-1));
	    );
	);
    X )

genericSequenceOfElements (Ideal,ZZ) := (K,l) -> (
     F := flatten degrees K;
     D := {};
     for i from 1 to l do (
     	  F = random F;
     	  D = append(D,first F + random l);
     	  );
     genericSequenceOfElements(K,D) )

----------------------------------------------------------------------

regularSequenceOfGenerators = method ();

regularSequenceOfGenerators (Ideal,List) := (K,D) -> (
    l := #D;
    if l > grade K then (
	<< l << " > grade of ideal" << endl << flush;
	X := zeroIdeal (ring K);
	)
    else (
	i := 0;
	X = genericSequenceOfGenerators (K,D);
     	while grade X != l and i < 100 do (
	    X = genericSequenceOfGenerators (K,D);
	    i=i+1; 
	    );
	);
    X )

regularSequenceOfGenerators (Ideal,ZZ) := (K,l) -> (
     F := flatten degrees K;
     D := {};
     for i from 1 to l do (
     	  F = random F;
     	  D = append(D,first F);
	  F = drop(F,1);
     	  );
     regularSequenceOfGenerators(K,D) )

regularSequenceOfGenerators Ideal := K -> (
    regularSequenceOfGenerators(K,grade K)
    ) 

----------------------------------------------------------------------

degreeIdeal = (K,d) -> (
    X := ideal();
    for j from 0 to (numgens K - 1 ) do (
	if (degree K_j)#0 == d then X = X + K_j;
	);
      X
      )
    
regularSequenceOfGeneratorsOfMinDeg = method();
    
regularSequenceOfGeneratorsOfMinDeg Ideal := K -> (
     F := unique flatten degrees K;
     D := {};
     X := ideal();
     g := 0;
     while #D < grade K do (
	 X = X + degreeIdeal(K,first F);
	 g = grade X - #D; 
	 for i from 1 to g do D = append(D,first F);
	 F = drop(F,1);
	 );
     regularSequenceOfGenerators(K,D)
     )

----------------------------------------------------------------------
	  
regularSequenceOfElements = method ();

regularSequenceOfElements (Ideal,List) := (K,D) -> (
    l := #D;
    if l > grade K then (
  	<< l << " > grade of ideal " << endl << flush;
  	X := zeroIdeal (ring K)
	)
    else (
	i := 0;
     	X = genericSequenceOfElements (K,D);
     	while grade X != l and i < 100 do (
	    X = genericSequenceOfElements (K,D);
            i=i+1; 
	    );
	);
    X )

regularSequenceOfElements (Ideal,ZZ) := (K,d) -> (
     l := grade K;
     D := for i from 1 to l list d;
     regularSequenceOfElements(K,D)
     )

----------------------------------------------------------------------
 
genericLink = method ();

genericLink(Ideal,List) := (K,D) -> (
     X := regularSequenceOfGenerators (K,D);
     if not isZeroIdeal X then (
	  J := X:K
	  )
     else (
	  J = zeroIdeal(ring K)
	  );
     {J,X}
     )

genericLink (Ideal) := K -> (
     X := regularSequenceOfGenerators K;
     if not isZeroIdeal X then (
	  J := X:K
	  )
     else (
	  J = zeroIdeal (ring K)
	  );
     {J,X}
     )

genericLink(Ideal,ZZ) := (K,d) -> (
     X := regularSequenceOfElements (K,d);
     if not isZeroIdeal X then (
	  J := X:K
	  )
     else (
	  J = zeroIdeal(ring K)
	  );
     {J,X} 
     )

----------------------------------------------------------------------

genericLinkOfMinDeg = method ();

genericLinkOfMinDeg (Ideal) := K -> (
     X := regularSequenceOfGeneratorsOfMinDeg K;
     if not isZeroIdeal X then (
	  J := X:K
	  )
     else (
	  J = zeroIdeal (ring K)
	  );
     {J,X}
     )

----------------------------------------------------------------------

randomIdeal = (L,Q) -> (
    ideal for l in L list random(l,Q)
    )

-- randomIdealFromDual = (L,Q) -> (
--     ideal fromDual matrix{for l in L list random(l,Q)}
--     )

monomialCount = I -> (
    sum for i from 0 to numgens I -1 list numgens ideal monomials I_i
    )
end 

---------------------------------------------------------------------------------
uninstallPackage "TorAlgebraTools"
restart
installPackage "TorAlgebraTools"
check "TorAlgebraTools"
loadPackage "TorAlgebraTools"

needsPackage "TorAlgebra"
needsPackage "TorAlgebraTools"


boij1 = (e,t,s,n,i) -> (
    binomial(t-1+i-1,i-1)*binomial(t-1+e,e-i)-n*binomial(s-t+e-i,e-i)*binomial(s-t+e,i-1)
    )

boij2 = (e,t,s,n,i) -> (
    n*binomial(s-t+e-i-1,e-i-1)*binomial(s-t+e,i)-binomial(t-1+i,i)*binomial(t-1+e,e-i-1)
    )

boij2(3,2,2,5,2)

Q = ZZ/53[x,y,z]
I = randomIdeal( {3,3,3,4,4,5} , Q );
grade I

genericSequenceOfGenerators( I, {3,4,5} )
genericSequenceOfGenerators( I, 4 )

genericSequenceOfElements( I, {5,6,7} )
genericSequenceOfElements( I, 4 )

regularSequenceOfGenerators ( I, {3,3,4} )
regularSequenceOfGenerators ( I, 3 )
regularSequenceOfGenerators ( I )
regularSequenceOfGeneratorsOfMinDeg ( I )

regularSequenceOfElements ( I, {5,5,8})
regularSequenceOfElements ( I, 3 )


numgens X
regularSequenceOfGeneratorsOfMinDeg(I)

torAlgData(Q/I)

K = I

for i from 0 to 10 list hf(3,i)
hvectorCompressed(3,{4,5})
torAlgData (Q/I)
L = {2,3}
I = ideal fromDual matrix{for l in L list random(l,Q)}
mingens I

X = genericSequenceOfGenerators(I,{3,3,4})
X = genericSequenceOfGenerators(I,4)

mingens X
hvectorCompressed({5,8})

isZeroIdeal soc (Q/ideal(x^2))
hvector ideal(x^2)

for i from 0 to 2 do (
    I = ideal (random(3,Q),random(3,Q),random(3,Q),random(4,Q),random(4,Q))
    print (mingens I)
    soc(Q/I)
    print (hvector(Q/I))
     )

hv = hvectors({4,4})

last hv
for i from 0 to length hv -1 do print hv#i

 
HF
hvectors({8,8})
Q = ZZ/1747[x,y,z]
I = ideal(x^3,y^3,z^4)
grade I
J = ideal(x^3-x*y,y^3,z^4)
grade J
isPerfect I
isPerfect J

K = ideal(x^2,x*y,x*z)
isPerfect K
grade K
isZeroIdeal K

L = ideal(x^2+x^3,x*y,x*z)
isPerfect L
grade L
isZeroIdeal L

I = ideal fromDual matrix{{random(8,Q),random(9,Q)}};

torAlgFormat I
last torAlgFormat(Q/I)
hvector I
isCompressed I

I = ideal fromDual matrix {{x*y*z,x^3}}
isPerfect I
hvector(Q/I)
isCompressed I

grade I
torAlgClass(Q/I)
soc(Q/I) 
socdeg(Q/I)
hilbertFunction(0,Q/I)

hvector(Q/I)

soc(Q/I) == zeroIdeal(Q/I)

J = ideal(x^2,x*y)
degrees soc(Q/J)
J = genericLink I
grade J#0
torAlgClass(Q/J#0) 

K = promote(ideal(),Q)
isZeroIdeal K

D = flatten degrees L
random D
Q = QQ[x]
random(0,Q)

order(x^3-y^4)

-------------------------------- linkage ---------------------------



------------ BR linkage ---------------------

BRLink = F -> (
     Q := ring F;
     D := F.dd_1;
     blocks := new MutableHashTable; 
     coldegrees := flatten  (degrees D)#1;
     for i in unique coldegrees do ( blocks#i = 0 );
     for i from 0 to ( length coldegrees - 1 ) do (
     	  j := coldegrees#i;
     	  blocks#j = blocks#j + 1;
     	  );
     P := map(Q^0,Q^0,0);
     for i in unique coldegrees do (  
     	  m := numrows P;
     	  n := numcols P;
     	  P = (P|map(Q^m,Q^(blocks#i),0))||(map(Q^(blocks#i),Q^n,0)|random(Q^(blocks#i),Q^(blocks#i)));
	  );
     P = map(source D, source D, P);
     A := D*P;
     m := numrows A;
     n := numcols A;
     L := {};
     for i from 1 to m+2 do  L = append(L,1);
     for i from 1 to n-m-2 do L = append(L,0);
     K := ideal(promote(0,Q));
     j := 0;
     while j < 10 and not isPerfect K do (
     	  j = j+1;
     	  L = random L;
     	  P = mutableMatrix map(id_(Q^n));
     	  for i from 0 to n-1 do (
     	       P_(i,i) =L#i;
     	       );
     	  P = map(source A, source A, matrix P);
     	  B := A*P;
     	  N := coker B;
     	  K = fittingIdeal(0,N);
     	  );
     M := coker A;
     X := dual res prune ker inducedMap(M,N);
     X[-length X]
     )

BRLinkIdeal = I -> (
     F := dual res I;
     F = F[-length F];
     X := BRLink F;
     if rank X_3 == 1 then (
	  X = (dual X)[-length X];
	  ideal X.dd_1
	  )
     else (
	  Y := BRLink X;
     	  Y = (dual Y)[-length Y];
     	  ideal Y.dd_1
	  )
     )

BRDoubleLinkIdeal = I -> (
     F := dual res I;
     F = F[-length F];
     X := BRLink( BRLink F );
     X = (dual X)[-length X];
     ideal X.dd_1
     )


--- Presentation and verification of BCGHT data ---

bcghtIs = (R,cls,h,p,q,r) -> (
     bcght := bcghtData R;
     if ( bcght#"cls" == cls
  	  and bcght#"h" == h 
  	  and bcght#"p" == p 
  	  and bcght#"q" == q
  	  and bcght#"r" == r ) then true 
     else false
     )

bcghtIsLN = (R,l,n) -> (
     bfm := collectData prune R;
     f:=bfm#"f";
     if ( f#1-1 == l and f#3 == n ) then true else false
     )

bcghtClass = R -> (
     bcght := bcghtData R;
     bcght#"cls"
     )

bcghtH = R -> (
     bcght := bcghtData R;
     bcght#"h"
     )

bcghtP = R -> (
     bcght := bcghtData R;
     bcght#"p"
     )

bcghtQ = R -> (
     bcght := bcghtData R;
     bcght#"q"
     )

bcghtR = R -> (
     bcght := bcghtData R;
     bcght#"r"
     )

bcghtLN = R -> (
     bcght := bcghtData R;
     (bcght#"l",bcght#"n")
     )

bcghtFormat = R -> (
     bfm := collectData prune R;
     f := bfm#"f";
     << " Format " << ( f#0, f#1, f#2, f#3 ) << endl << flush;
     )

bcghtBetti = R -> (
     bfm := collectData R;
     b := bfm#"b";
     << " Betti " << ( b#0, b#1, b#2, b#3, b#4 ) << endl << flush;
     )

bcghtBass = R -> (
     bfm := collectData prune R;
     m := bfm#"m";
     << " Bass " << ( m#0, m#1, m#2 ) << endl << flush;
     )

bcghtDATA = R -> (
     bcght := bcghtData R;
     bcght#"cls", bcght#"h", bcght#"p", bcght#"q", bcght#"r"
     )


--- Tallying the outcome of experiments ---

countFormat = (R,count) -> (
     F := torAlgFormat R;
     D := bcghtDATA R;
     if count#?F then () else count#F = new MutableHashTable;
     if count#F#?D then count#F#D = count#F#D + 1 else count#F#D = 1;
     )

countClass = (R,count) -> (
     F := bcghtLN R;
     D := bcghtDATA R;
     if count#?D then () else count#D = new MutableHashTable;
     if count#D#?F then ( 
	  count#D#F = count#D#F + 1 
	  ) 
     else (
	  count#D#F = 1
	  );
     )

isbetterexample = (R,d,l) -> (
     if degree ideal R < d then (
	  true
	  )
     else ( if degree ideal R > d then (
	       false
	       )
	  else ( if length toString mingens ideal R < l then (
		    true
		    )
	       else (
		    false
		    )
	       )
	  )
     )

storeexample = (R,count) -> (
     F:= bcghtLN R;
     D:= bcghtDATA R;
     count#F#D#"example"#"ideal" = ideal R;
     count#F#D#"example"#"degree" = degree ideal R;
     count#F#D#"example"#"length" = length toString mingens ideal R;
     )

countFormatAndStore = (R,count) -> (
     F:= bcghtLN R;
     D:= bcghtDATA R;
     if count#?F then () else count#F = new MutableHashTable;
     if count#F#?D then (
	  count#F#D#"number" = count#F#D#"number" + 1;
	  if isbetterexample(R,count#F#D#"example"#"degree",count#F#D#"example"#"length") then (
	       storeexample(R,count)
	       )
	  else ()
	  )
     else (
	  count#F#D = new MutableHashTable;
  	  count#F#D#"number" = 1;
    	  count#F#D#"example" = new MutableHashTable;
    	  storeexample(R,count);
	  );
     )

countLinkClass = (R,S,count) -> (
     F := bcghtLN R;
     G := bcghtLN S;
     D := bcghtDATA R;
     E := bcghtDATA S;
     if count#?D then () else count#D = new MutableHashTable;
     if count#D#?F then () else count#D#F = new MutableHashTable;
     if count#D#F#?G then () else count#D#F#G = new MutableHashTable;
     if count#D#F#G#?E then ( count#D#F#G#E = count#D#F#G#E + 1 ) else count#D#F#G#E = 1;
     )

countLinkFormat = (R,S,count) -> (
     F := bcghtDATA R;
     G := bcghtDATA S;
     D := bcghtLN R;
     E := bcghtLN S;
     if count#?D then () else count#D = new MutableHashTable;
     if count#D#?F then () else count#D#F = new MutableHashTable;
     if count#D#F#?G then () else count#D#F#G = new MutableHashTable;
     if count#D#F#G#?E then ( count#D#F#G#E = count#D#F#G#E + 1 ) else count#D#F#G#E = 1;
     )


--- Routines for experiments ---

randomLink = K -> (
     X := ideal ();
     for i from 1 to 3 do ( 
	  j := random(ZZ,Height => numgens K),
     	  X = X + ideal(K_j) 
	  );
     X:K
     )

randomSubideal = (K,d) -> (
     m := numgens K;
     J := ideal ();
     for i from 0 to d + random( ZZ, Height => m-d ) do ( 
	  j := random(ZZ,Height => m),
	  J = J + ideal(K_j)
	  );
     J )

multiplyGenerator = (K,i,M) -> (
     J := ideal ();
     for j from 0 to ( numgens K - 1 ) do ( 
	  if i==j then J = J + M*ideal(K_j) else J = J + ideal(K_j) 
	  );
     J )

removeGenerator = (K,i) -> (
     J := ideal ();
     for j from 0 to ( numgens K - 1 ) do ( 
	  if i==j then () else J = J + ideal(K_j) 
	  );
     J )

pinchGenerator = (K,i,j) -> (
     J := ideal (K_i-K_j);
     for k from 0 to ( numgens K - 1 ) do ( 
	  if ( k==i or k==j ) then () else J = J + ideal(K_j) 
	  );
     J )




end

beginDocumentation()

doc ///
Key
  Demo
Headline
  Demo package
Description
  Text
  Example
Caveat
SeeAlso
///


doc ///
Key
 f
Headline
 Subtracts 2
Usage
 f x
Inputs
 x:ZZ
Outputs
 :ZZ
 x-2     
Consequences
Description
  Text
  Example
  Code
  Pre
Caveat
SeeAlso
///

end

TEST ///
-- test code and assertions here
-- may have as many TEST sections as needed
///

needsPackage "LexIdeals"

hvectors = method();

hvectors (List,ZZ) := (S,t) -> (
    s := max S;
    C := hvectorCompressed S;
    c := sum for h in C list h;
    AH := {for i from 0 to t-1 list hf(3,i)};
    for i from t to s-1 do (
    	l := length AH - 1;
    	BH := {};
    	for j from 0 to l do (
	    for k from 1 to C#i do (
	    	B := append(AH#j,k);
	    	if isHF B then ( BH = append(BH,B) );
	    	);
	    );
    	AH = BH;
    	);
    if s == min S then AH = for H in AH list append(H,2);
    if s != min S then AH = for H in AH list append(H,1);
    hv :={};
    for H in AH do (
    	B := {1,0, H#2-6};
    	for i from 3 to s do (
	    B = append(B,H#i - 3*H#(i-1) + 3*H#(i-2) - H#(i-3));
	    );
    	B = B|{-3*H#s + 3*H#(s-1) - H#(s-2), 3*H#s - H#(s-1), -H#s};
    	sm := sum for b in B list abs(b);
    	if sm <= 14 and mod(sm,2) == 0 then (
	    hv = append(hv,(H,c - (sum for h in H list h), B,sm));
	    );
    	);
   hv
    )

x = hvectors ({4,4},2)
for i from 0 to #x - 1 do print(x#i)

hvectors (List) := S -> (
    hvectors(S,2)
    )


f = x -> (x+2)
f(9)

R = QQ[a,b,c,d,e]
I = monomialCurveIdeal(R,{4,5,6,9})
regularSequenceOfGenerators (I,{3,6})
