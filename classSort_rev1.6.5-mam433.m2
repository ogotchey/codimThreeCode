needsPackage "RandomIdeals"
needsPackage "TorAlgebra"

Type == Type := (j,k) -> if toString j == toString k then true else false

dbg = false;
printD = arg->(if dbg then print(arg));
metric = new MutableList from {0,0,0}

dir = "data/";
logfile = "log.txt";

Q = (ZZ/3)[x,y,z];

quickn = arg -> (degree( (res arg)_3));

roundedMean = arg -> (floor((sum arg)/(#arg)));

classDat = new MutableHashTable;
clear = i -> (classDat = if not (fileExists (dir|"classDat.txt")) then new MutableHashTable else new MutableHashTable from apply(value get (dir|"classDat.txt"), (a,b) -> (apply(a,k->if toString class k == "Symbol" then toString k else k), (ideal b#0, b#1)));
    fileDescr = new List;
    changeList = new List;
    if(not isDirectory dir) then mkdir dir;
    )
clear()

cs = f -> (g:=toString(f#0)|"/"; f = f_{1..(#f-1)}; for h in f do g = g|h|"-"; g=substring(g,0,length(g)-1)|".txt"; dir|g)
fileHandler = arg -> (
    if((f := select(fileDescr, i -> net i == cs(arg))) != {}) then f 
    else (fileDescr = append(fileDescr, f=openOutAppend(cs(arg)));
	f)
)

randomNonZero = (i,j,n) -> toSequence (for m from 0 to n-1 list random(j-i+1)+i);
 --randomHomogeneousPolynomial (numTerms, Degree)
randomHomogeneousPolynomial = arg -> (if arg#0 == 0 then random(arg#1,Q) else(
	if(arg#0 >= 6 and arg#1 <= 2) then(
	    sum flatten entries basis(2,Q)
	)	
	else (
	    j:=0; for i from 1 to arg#0 do j=j+( (random {-1,1})#0 *randomMonomial(arg#1,Q)); 
	    j)
	)
    );

artinianify = method()
artinianify (Ideal,ZZ) := Ideal => (I,highDeg) -> (
    m := numcols mingens I;
    printD("artinifying...");
    if dbg then tmp = currentTime();
    i := 0;
    p := flatten entries vars Q;
    while(codim I != 3 and i<3) do(
	L := random flatten entries mingens I;
    	for j from 0 to (#L)-1 do(
	    M := replace(j,L#j+((p#i)^((degree L#j)#0)),L);
	    if numcols mingens ideal M == m then( L = M; break; )
	    );
	i = i+1;
	I = ideal toList L;
	);
    printD("artinified");
    if dbg then metric#1 = metric#1 + currentTime()-tmp;
    I)

--randomHomogeneousIdeal
randomHomogeneousIdeal = method(Options=>true)
randomHomogeneousIdeal (Sequence, ZZ) := Ideal => {useN=>false, nTries=>0,maxTries=>10} >> opts -> arg ->(
    printD("searching for ideal...");
    if(opts.nTries <= opts.maxTries) then
    (
    if dbg then tmp = currentTime();
    arg = sequence arg;
    j := ideal apply (arg#0, k-> randomHomogeneousPolynomial(arg#1,k));
    
    --using m
    if(not opts.useN) then (
    l := 0;
    while (numcols mingens j) < #(arg#0) and l<10 do (
	j = j + ideal randomHomogeneousPolynomial(arg#1, (random (toList arg#0))#0
	); 
	l=l+1;
    );
    if(numcols mingens j < #(arg#0)) or (arg#1 == 1 and codim j != 3) then (
	k := arg#0;
	k = toSequence random replace(0,k#0,sort toList k);
	randomHomogeneousIdeal(k,arg#1,nTries=>(opts.nTries+1),maxTries=>opts.maxTries)
    ) 
    else(
    	if codim j != 3 then j = artinianify(j,max(arg#0));
	printD("found ideal!");
    	if dbg then metric#0 = metric#0 + currentTime()-tmp;
    	ideal mingens j
    )
    )
    --using n
    else(
	I := ideal mingens ideal fromDual matrix {toList apply(arg#0, k-> randomHomogeneousPolynomial(arg#1,k))};
	r := res I;
	if(#(arg#0) != rank r_3) then (randomHomogeneousIdeal(toSequence random replace(0,(arg#0)#0, sort toList arg#0),arg#1,nTries=>(opts.nTries+1),useN=>true) ) else I
    )

)
    else (ideal 0_Q)
)


--randomHomogeneousIdeal (mn, (d1, d2), s)
randomHomogeneousIdeal (ZZ,Sequence,ZZ) := Ideal => {useN=>false, nTries=>0,maxTries=>10} >> opts -> (mn,d,s) -> (
    randomHomogeneousIdeal(randomNonZero(d#0,d#1,mn),s,maxTries=>opts.maxTries,useN=>opts.useN)
)

maxTerms = method()
maxTerms Ideal := ZZ => arg -> (max(apply(flatten entries mingens arg, lambda->#(terms lambda))))

toFile = arg -> (if #(sequence arg) == 0 then arg = dir; arg|"class.txt" << printClass() << close; arg|"classDat.txt" << apply(pairs classDat, (x,y) -> (x, (toString gens y#0, y#1)))  << close;)

opts = new List from {fieldChar=>3, logging=>false, numTerms=>0, mn=>5, lowDeg=>2, highDeg=>8, degSeq=>sequence 0, checkIn=>0, strictTerms=>false, maxTries=>10, useN=>false}--, record=>true}
-- if degSeq is the zero sequence, the main function will default to randomly generating ideals according to the first four options
-- if it is not, the main function will ignore the first four options and generate ideals with degrees from degSeq
-- if checkIn is nonzero, the main function will print out a "check in" when the number of ideals computed is divisible by checkIn
-- dummy = torAlgData(Q/(ideal "x7,y7,z7"));
main = method(Options=>true)
main ZZ := opts >> o -> a -> (
   -- numTermsMax := ceiling( (1/4)*binomial( (if o.degSeq == sequence 0 then floor ((o.lowDeg+o.highDeg)/2) else roundedMean o.degSeq) + 2,2));
   -- if  o.numTerms > numTermsMax and o.degSeq == sequence 0 then ( if(o.logging == true) then ((openOutAppend logfile) << "Warning: user-defined numTerms exceeds upper bound\n" << close););
    if(char Q != o.fieldChar) then (if o.fieldChar != 0 and not isPrime o.fieldChar then print("Error: bad field") else( tmpChar:=char Q; Q = (ZZ/o.fieldChar)[x,y,z]));
    clear();
    tobelogged := ("\nMain Routine started at " | toString(currentTime()) | "\nwith options: " | toString o | "\n");
    print tobelogged;
    (openOutAppend logfile) << tobelogged  << close;
    t := currentTime();
    distinct = new List from {};
    b := 0;
    for i from 0 to (a-1) do(
	if o.checkIn != 0 and i%o.checkIn == 0 then print("Checking in every " | toString o.checkIn | " ideals... done " | toString i | " so far\n");
        p := (if o.degSeq == sequence 0 then randomHomogeneousIdeal(o.mn, (o.lowDeg, o.highDeg), o.numTerms, maxTries=>o.maxTries, useN=>o.useN) else randomHomogeneousIdeal(o.degSeq,o.numTerms,maxTries=>o.maxTries,useN=>o.useN)); 
	-- check for codim 3, homogeneous(ness), # of terms
	if(codim p == 3 and isHomogeneous p and (not o.strictTerms or maxTerms p == o.numTerms) and min flatten degrees p > 1 and #(flatten entries mingens p) <= 12 and quickn p<= 10 ) then (
	    --print("found ideal of codim 3");
	    printD("classifying");
	    if dbg then tmp = currentTime();
	    data := torAlgData(Q/p);
	    if dbg then metric#2 = metric#2 + currentTime() - tmp;
	    printD("classified!");
	    data = ( data#"m", data#"n", data#"Class", data#"p", data#"q", data#"r");
	    actualTerms = (if (mt := maxTerms p) < 3 then mt else 3);
	    if(not isDirectory(dir | (toString actualTerms))) then mkdir(dir|(toString actualTerms));
	    --if(record==true) then (g
	        if classDat#?data then (
	    	    if length toString net gens (classDat#data)#0 > length toString net gens p then (classDat#data = drop(insert(0,p,classDat#data),{1,1});
	    	        fileHandler(sequence actualTerms | data) << toString gens p << endl;);
		    classDat#data = drop(insert(1,(classDat#data)#1 + 1,classDat#data), {2,2});
		    if(not member(data,distinct)) then distinct = append(distinct, data);
	        )
	        else(
	    	    classDat = merge(classDat, new MutableHashTable from {data => (p,1)}, (j,k)->j);
	    	    fileHandler(sequence actualTerms | data) << toString gens p << endl;
	    	    changeList = append(changeList, data);
		    distinct = append(distinct, data);
	        );
	    b = b+1;
	-- debug: print peek nClass;
    	)
    	--else (
	   -- print("can't classify: m = " | toString (#(flatten entries mingens p)) | "; n = " | toString quickn p)
	--);
    );
    scan(fileDescr, k -> (k << close));
    fileDescr = new List;
    toFile();
    if(char Q != o.fieldChar) then (Q = (ZZ/tmpChar)[x,y,z]);
    t = currentTime() - t;
    ret := sort changeList;
    if(o.logging==true) then (fi := openOutAppend(logfile); for i in ret do (fi << i << endl); fi << close);
    tobelogged = ("\nMain Routine finished:\nat " | toString(currentTime()) | "\nran for " | toString t | " seconds, \nclassified " | toString b | " ideals,\n generated " | toString (#distinct) | " distinct classes,\nand discovered " | toString (#changeList) | " new classes\n");
    print tobelogged;
    (openOutAppend logfile) << tobelogged << close;
    ret
)


--housekeeping functions
getClass = arg -> (if arg != () then classDat#arg else peek classDat)
getIdeal = arg -> (if arg != () then (getClass(arg))#0)
getCount = arg -> (if arg != () then (getClass(arg))#1)
getGenType = arg -> (select(
	select(readDirectory(dir), lambda->isDirectory(dir|lambda)),
	lambda-> (fileExists(cs(sequence(lambda)|arg)))))
getHist = arg -> (l := flatten for i in getGenType(arg) list(
	print("this class can be generated by a(n) " | i | "-ideal with examples:");
	f := fileHandler(sequence(i)|arg);
        ret = apply(lines get f, l->ideal value l);
	ret);
    print (#l); l);

printClass = nt -> MatrixExpression (apply (sort pairs classDat, k -> flatten (toList k#0 | {(k#1)#1} | {net gens ((k#1)#0)})));
