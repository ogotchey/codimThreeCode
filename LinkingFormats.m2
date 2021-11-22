needsPackage "BoijSoederberg"

-- Auxiliary functions -----------------------------------------------

-- Functions for finding regular sequences to link over

genericGenerator := (K,d) -> (
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

regularSequenceOfGenerators = method ();

regularSequenceOfGenerators (Ideal,List) := (K,D) -> (
    l := #D;
    if l > codim K then (
	<< l << " > grade of ideal" << endl << flush;
	X := ideal(0_(ring K));
	)
    else (
	i := 0;
	X = genericSequenceOfGenerators (K,D);
     	while codim X != l and i < 1000 do (
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


-----------------------------------------------------------------------------

-- Drop one instance of an element from a list

dropFromList := (L,l) -> (
    drop(L, {position(L, i -> i==l),position(L, i -> i==l)})
    )

 
-- Turn a graded format into matrix

list2mat = (E,F,G) -> (
    r := max G - 3;
    map(ZZ^(r+1),ZZ^4, {(0,0) => 1}|(for i from 0 to r list (i,1) => number(E,j -> j == i+1))|
	(for i from 0 to r list (i,2) => number(F,j -> j == i+2))|
	(for i from 0 to r list (i,3) => number(G,j -> j == i+3)))
    )

list2betti = (E,F,G) -> (
    mat2betti list2mat(E,F,G)
    )


-- Make Hilbert function from a graded format

EFGHF = (E,F,G) -> (
    T := QQ[t];
    p := 1  - sum apply(E,i -> t^i) + sum apply(F,i -> t^i) - sum apply(G,i -> t^i);
    p = sub(p/(1-t)^3,T);
    apply(1 + (degree p)#0,i -> sub(coefficient(t^i,p),ZZ))
    )

-- Make degree format of complete intersection


ciList := K -> (
    (K, apply(subsets(K,2), i -> sum i),{sum K})
    )


-- Test for validity of graded formats

isValidBetti = (E,F,G) -> (
    E = sort E;
    F = sort F;
    G = sort G;
    if E#0 > 0 and F#0 > 1 and G#0 > 2
    and ( sum E - sum F + sum G == 0 )
    and ( sum apply(E, i -> i^2) - sum apply(F, i -> i^2)  + sum apply(G, i -> i^2) == 0 )
    and ( numerator(( sum apply(E, i -> i^3) - sum apply(F, i -> i^3)  + sum apply(G, i -> i^3) )/6) == sum EFGHF(E,F,G) )    
    and (E#1 + 1 <= first F) and (last E + 1 <= last F) and (last F <= sum last subsets(E,2)) 
    and (F#1 + 1 <= first G) and (last F + 1 <= last G) and (last G <= sum last subsets(F,2))
    and ( try decomposeBetti list2betti(E,F,G) then true else false ) then true else false
     )

isValidBetti1 = (D,E,F,G) -> (
    D = sort D;
    E = sort E;    
    F = sort F;
    G = sort G;
    if D#0 > 0 and E#0 > 1 and F#0 > 2 and  G#0 > 3
    and ( sum D - sum E + sum F - sum G == 0 )
    and ( sum apply(D, i -> i^2) - sum apply(E, i -> i^2)  + sum apply(F, i -> i^2) - sum apply(G, i -> i^2) == 0 )
    and (E#1 + 1 <= first F) and (last E + 1 <= last F) and (last F <= sum last subsets(E,2)) 
    and (F#1 + 1 <= first G) and (last F + 1 <= last G) and (last G <= sum last subsets(F,2))
    and ( try decomposeBetti list2betti(E,F,G) then true else false ) then true else false
     )

-- Checks related to multiplication

pGuaranteedZero = (E,F) -> (
    P := unique subsets(E,2);
    p := unique apply(P, i -> sum i);
    if 0 == #((set p) * (set F)) then true else false
)

qGuaranteedZero = (E,F,G) -> (
    q := unique flatten apply( unique E, i -> apply(unique F, j -> i+j));
    if 0 == #((set q) * (set G)) then true else false
)

pGuaranteedPositive = (E,F) -> (
    test := false;
    P := unique subsets(E,2);
    scan(P, i -> if sum i == first delete(i#0,delete(i#1,F)) then test = true);
    p := sort unique apply(P, i -> sum i);
    if (last p == last F) then test = true;
    test
)

-- test for type 2 using Brown

testBrown = (E,F,G) -> (
    test := false;
    if #G != 2 then test = true else (
    	P := unique subsets(E,2);
    	S := delete(null,apply(P, i -> if #i == 2 and sum i == first delete(i#0,delete(i#1,F)) then {i#0,i#1,sum i}));
    	if sum(last P) == last F then S = S|{{(last P)#0, (last P)#1, last F}};
    	if #S == 0 then test = true;
    	if #S == 1 then (
	    S = flatten S;
	    F = dropFromList(F,S#2);
    	    q0 := apply(F, i -> i + S#0);
	    q1 := apply(F, i -> i + S#1);
	    if mod(#E,2) == 1 then (
	    	q := toList (set q0*(set G)*set q1);
    	    	Q := apply(q, i  -> {i-S#0,i-S#1});
	    	scan(Q, i -> test = test or member(i#1,dropFromList(F,i#0)));
	    	);
	    if mod(#E,2) == 0 then (
	    	u := #(unique G);
	    	q0 = toList (set q0*(set G));
	    	q1 = toList (set q1*(set G));
	    	if #q0 == u and member(last G - S#0,dropFromList(F,first G - S#0)) then test = true;
	    	if #q1 == u and member(last G - S#1,dropFromList(F,first G - S#1)) then test = true;	    
	    	);
    	    );
	);
    test
    )

-- Comparing to a Gorenstein ring

testGorenstein = (GorEFG, EFG) -> (
    test := false;
    E := sort EFG#0;
    F := sort EFG#1;
    G := sort EFG#2;
    m := #E;
    s := last G;
    H := unique delete(null,apply(F, i -> if i >= first G then i));
    if #H != 0 then (
	T := tally F;
	U := tally E;
	GorEFG = delete(null,apply(GorEFG, (e,f,g) -> if (
		    t := tally f;
		    xx := true;
		    try scan(H, h -> xx = xx and T#h == t#h) then xx else false 
		    )
		and (
		    xx = true;
		    scan(f, i -> xx = xx and (i <= first G - 2 or (member(i,F) and t#i <= T#i)));
		    xx
		    )
		and (
    		    u := tally e;
		    xx = true;
		    scan(e, i -> xx = xx and (i <= first G - 3 or (member(i,E) and u#i <= U#i)));
		    xx
		    )
		then (e,f,g)
		)
	    );
	);
    B := list2mat(E,F,G);
    BT := apply(GorEFG, b -> (bt := list2mat b;
    	M := mutableMatrix (B-bt||matrix{apply(4, i -> 0)});
    	    scan(numcols M , j -> scan(numrows M - 1, i -> if (x := M_(i,j)) < 0 then (M_(i,j) = 0; M_(i+1,j-1) = M_(i+1,j-1) - x)));
            mat2betti matrix(entries M))
    	); 
    -- BT := apply(GorEFG, b -> (
    -- 	    bt := list2mat b;
    -- 	    M := mutableMatrix (B-bt||matrix{apply(4, i -> 0)});
    -- 	    scan(numcols M , j -> scan(numrows M - 1, i -> if (x := M_(i,j)) < 0 then (M_(i,j) = 0; M_(i+1,j-1) = M_(i+1,j-1) - x)));
    --         M = matrix(entries M);
    -- 	    M0 := entries M_0;
    -- 	    M1 := entries M_1;
    -- 	    M2 := entries M_2;
    -- 	    d := flatten apply(#M0, i -> apply(M0#i, j -> i ));
    -- 	    e := flatten apply(#M1, i -> apply(M1#i, j -> i+1));
    -- 	    f := flatten apply(#M2, i -> apply(M2#i, j -> i+2));
    -- 	    ge := b#0;
    -- 	    gf := F;
    -- 	    scan(d, i -> ge = delete(i,ge));	    
    -- 	    scan(f, i -> gf = delete(i,gf));
    -- 	    r := 0;
    -- 	    scan(ge, i -> ( if member(s-i,gf) then (r = r+1; gf = dropFromList(gf,s-i))));	    
    -- 	    if #d == 1 or (m == 5 and r <= 2) then mat2betti M else (if m > 5 and r <= m-2 then mat2betti M)
    -- 	    )
    -- 	);
    -- BT = apply(BT, bt -> ( M = matrix(bt); 
    -- 	    M0 := entries M_0;
    -- 	    M1 := entries M_1;
    -- 	    M2 := entries M_2;
    -- 	    d := flatten apply(#M0, i -> apply(M0#i, j -> i ));
    -- 	    e := flatten apply(#M1, i -> apply(M1#i, j -> i+1));
    -- 	    f := flatten apply(#M2, i -> apply(M2#i, j -> i+2));
    -- 	    scan(d, i -> E = delete(E,i));	    
    -- 	    scan(e, i -> if member(i,E) then E = dropFromList(E,i));
    -- 	    scan(f, i -> if member(i,F) then F = dropFromList(F,i));	    
    -- 	    r := 0;
    -- 	    )
    -- 	);
    for bt in BT do (
    	if test then break else (
    	    try decomposeBetti bt then test = true else test = false;
    	    )
    	);
    -- for bt in BT do (
    -- 	if test then break else (
    -- 	    M := matrix bt;
    --  	    M0 := entries M_0;
    --  	    M1 := entries M_1;
    --  	    M2 := entries M_2;
    --  	    M3 := entries M_2;	    
    --  	    d := flatten apply(#M0, i -> apply(M0#i, j -> i ));
    --  	    e := flatten apply(#M1, i -> apply(M1#i, j -> i+1));
    --  	    f := flatten apply(#M2, i -> apply(M2#i, j -> i+2));
    --  	    g := flatten apply(#M3, i -> apply(M3#i, j -> i+3));	    
    -- 	    print(d,e,f,g);
    -- 	    if isValidBetti1(d,e,f,g) then test = true else test = false;
    -- 	    )
    -- 	);
    test
    )

testLink = (E,F,G) -> (
    if #linkedGradedFormats(E,F,G) > 0 then true else false
    )

-- Main functions

-- Generate graded formats of Gorenstein rings

generateGorenstein = s -> (
    t := ceiling((s+1)/2);
    s = s + 3;
    g := {s};
    m := 1;
    EFG := {};
    while m < 2*t do (	
	m = m + 2;
    	E := apply(t, i -> {i + 1});
    	E = flatten (apply(E, e -> (for j from last e to s - 1 - first e list append(e,j))));
    	scan(m-2, i -> (E = flatten (apply(E, e -> (for j from last e to s - 1 - first e list append(e,j))))));
	EF := apply(E, e -> (e, sort apply(e, i -> s-i)));
    	efg := delete(null,apply(EF, (e,f) -> if isValidBetti(e,f,g) then (e,f,g)));	
	EFG = EFG|efg;
	);
    EFG
    )

-- Generate general graded formats

gradedFormats = method()

gradedFormats(ZZ,List) := (m,G) -> (
    G = sort apply(G, i -> i + 3);
    n := #G;
    s := sum G;
    -- generators of F1
    E := apply(first G - 3, i -> {i + 2});
    scan(m-1, i -> (E = flatten (apply(E, e -> (for j from last e to last G - 2 list append(e,j))))));
    -- generators of F2
    EF := {};
    EF = flatten flatten apply(E, e -> for j from e#1 + 1 to min(first G - 1, floor((s + sum e)/(m + n - 1))) list append(EF,(e,{j})));
    scan(m+n-2, i -> ( EF = flatten flatten apply(EF, (e,f) -> for j from last f to min(last G - 1, floor((s + sum e + sum f)/(m + n - 2 - i))) list (e,append(f,j)))));
    -- purge invalid formats
    EFG := {}; 
    scan(EF, (e,f) -> if isValidBetti(e,f,G) then EFG = append(EFG,(e,f,G)));         
    EFG = delete(null,apply(EFG, i -> if testBrown i then i));
    GorFormats := generateGorenstein(last G-3);
    EFG = delete(null,apply(EFG, i -> if testGorenstein(GorFormats,i) then i));
--    EFG = delete(null,apply(EFG, i -> if testLink i then i));
    EFG
    )

gradedFormats(List,List) := (E,G) -> (
    E = sort E;
    m := #E;
    G = sort apply(G, i -> i + 3);
    n := #G;
    s := sum G;
    -- generators of F2
    EF := {};
    EF = flatten flatten apply({E}, e -> for j from e#1 + 1 to min(first G - 1, floor((s + sum e)/(m + n - 1))) list append(EF,(e,{j})));
    scan(m+n-2, i -> ( EF = flatten flatten apply(EF, (e,f) -> for j from last f to min(last G - 1, floor((s + sum e + sum f)/(m + n - 2 - i))) list (e,append(f,j)))));
    -- purge invalid formats
    EFG := {}; 
    scan(EF, (e,f) -> if isValidBetti(e,f,G) then EFG = append(EFG,(e,f,G)));     
    EFG = delete(null,apply(EFG, i -> if testBrown i then i));
    GorFormats := generateGorenstein(last G-3);
    EFG = delete(null,apply(EFG, i -> if testGorenstein(GorFormats,i) then i));
    EFG
    )

link = method()

link (Sequence,List) := (Fmt,K) -> (
    (E,F,G) := Fmt;
    s := sum K;
    scan(K, k -> E = dropFromList(E,k));
    (sort (K|apply(G, i -> s - i)), sort(apply(F, i-> s - i)), sort(apply(E,i -> s - i)))
)

link(Sequence, List, List) := (Fmt,K,L) -> (
    link(Fmt,K,L,{})
    )

link(Sequence, List, List, List) := (Fmt,K,L,M) -> (
    (E,F,G) := Fmt;
    (e,f,g) := ciList K;
    s := g#0;
    scan(L, l -> E = dropFromList(E,l));
    scan(L, l -> f = dropFromList(f,s-l));    
    scan(M, m -> F = dropFromList(F,m));        
    scan(M, m -> e = dropFromList(e,s-m));
    (sort(e|apply(G, i -> s -i)), sort(f|apply(F, i -> s -i)), sort apply(E, i -> s -i))
)

findLinks = (E,F,G) -> (
    Y := {("Linking format", (E,F,G))};
    P := unique subsets (E,3);
    for p in P do (
	(e,f,g) := link((E,F,G),p);
	if isValidBetti (e,f,g) then Y = append(Y,(p,(e,f,g),last G - last g));
	);
    Y
    )

linkedGradedFormats = (E,F,G) -> (
    Y := {};
    P := unique subsets (E,3);
    for p in P do (
	(e,f,g) := link((E,F,G),p);
	if isValidBetti (e,f,g) then Y = append(Y,(e,f,g));
	);
    Y
    )

------------
-- devspace
