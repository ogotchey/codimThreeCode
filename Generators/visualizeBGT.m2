R = (ZZ/3)[x,y,z]

tabtocsv := t->(
    outStrings := apply(t, i->(outString := ""; for j from 0 to (#i)-1 do (outString = (outString | (if j != 0 then "," else "") | toString(i#j))); outString));
    output := "";
    scan(outStrings, i->(output = output | i | "\n"));
    output);

if(not fileExists("classDat.txt")) then print "error: no classDat file";

classDat = new MutableHashTable from apply(value get ("classDat.txt"), (a,b) -> (apply(a,k->if toString class k == "Symbol" then toString k else k), (ideal b#0, b#1)));

mrange := (3,12);
nrange := (1,10);

maxr := 0;
maxp := 0;
rIndices := for m from mrange#0 to (mrange#1+1) list maxr do (maxr = maxr+max({(m-1),4})) ;
pIndices := for n' from -(nrange#1+1) to -(nrange#0) list maxp do (maxp = maxp+4);
maxr = max rIndices;
maxp = max pIndices;

rc2mnrp := (r,c) -> (position(rIndices, t->(t<=c),Reverse=>true)+3,
    10-position(pIndices, t->(t<=r),Reverse=>true),
    c-(select(rIndices, t->(t<=c)))#(-1),
    (select(pIndices, t->(t>r)))#0 - (r+1)    
    );

classornot := (m,n,r,p) -> (
	if(m==3) then (
	    if(n==1 and p==3 and r==3) then "C" else " "
        )
	else(
	    if(m==4) then (
		if(r==0 and p==3 and (n%2)!=0 and n>=3) then "T" else " "
		)
		else(
		     if(m==5) then (
			 if(n==1 and r==5 and p==0) then "G"
			 else(
			     if(n==2 and p==1 and r==2) then "B"
				    else(
					if(n==3) then " "
					else(
					    if(n>=4 and r==0 and p==3) then "T" else " "
					    )
					)
				    )
				)
			    
	    else(
		if(n==1) then (
		    if(r==m and p==0 and (m%2)!=0) then "G" else " "
		    )
		else(
		    if(n==2) then (
			if(p==0 and 2<=r and r<=(m-2)) then "G"
			else(
			    if(p==1 and r==2 and (m%2)!=0) then "B"
			    else " "
			    )
			)
		    else(
			if(n==3) then (
			    if(2<=r and r<=(m-2) and p==0) then "G"
			    else(
				if(r==2 and p==1) then "B"
				else " "
				)
			    )
			else(
				if(2<=r and r<=(m-2) and p==0) then "G"
				else(
				    if(r==2 and p==1) then "B"
				    else(
					if(r==0 and p==3) then "T"
					else " "
					)
				    )
				)
			    )
			)
		    )
		)
	    )	    
)


--	if (m == 3) then
--	( if (n==1 and q==1 and p==3) then 0 else " ")
--  if(n==(m-2) and p==n+1 and q==m-2) then 0
--  else(
--	if(p < n-1 and q < m-4) then 0
--	else(
--	    if((p==(n-1) and (q-(m-4))%2==0) or (q==(m-4) and (p-(n-1))%2==0)) then 0
--	    else " "
--	    )
--	)
--  )

classTab := table(maxp,maxr, (i,j)->rc2mnrp(i,j));
numTab := apply(classTab, i->(apply(i,j->(
	        cl:=classornot(j#0,j#1,j#2,j#3);
		k:=(
		    if(cl==" ") then (0,0," ",0,0,0) else (
		    if(cl=="B") then (
		        (j#0,j#1,"B",1,1,2)
		    )
		    else(
			if(cl=="T") then (
			    (j#0,j#1,"T",3,0,0)
			    )
			else(
			    if(cl=="G") then (
				(j#0,j#1,"G",0,1,j#2)
				)
			    else(
				if(cl=="C") then (
				    (j#0,j#1,"C",3,1,3)
				    )
				)
			    )
			)
		    ) 
		);
	        if(k==(0,0," ",0,0,0)) then " "
		else(
		   
		    if(classDat#?k) then (classDat#k)#1 else 0
	        )
	    )
)
)
)

numTabwithLabels := new List;
for i from 0 to maxp-1 do(
    (a,b) = toSequence ( (rc2mnrp(i,0))_{1,3} );
    numTabwithLabels = append(numTabwithLabels, {"n="|toString a,"p="|toString b}|(numTab#i));
)
rowlab := apply( (0..maxr-1), i->rc2mnrp(0,i) );
numTabwithLabels = prepend({,} | toList( apply(rowlab,lambda->("r="|toString lambda#2))),numTabwithLabels);
numTabwithLabels = prepend({,} | toList( apply(rowlab,lambda->("m="|toString lambda#0))),numTabwithLabels);
out := tabtocsv(numTabwithLabels);

export {"classTab","numTabwithLabels","tabtocsv","classornot","rc2mnrp"};

"seenBGT.csv" << out << close;
