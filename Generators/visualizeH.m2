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

maxp := 0;
maxq := 0;
pIndices := for m from mrange#0 to (mrange#1+1) list maxp do (if m>3 then maxp = maxp+m else maxp = maxp+4);
qIndices := for n' from -(nrange#1+1) to -(nrange#0) list maxq do (n:=(-n'); maxq = maxq+n);
maxp = max pIndices;
maxq = max qIndices;

rc2mnpq := (r,c) -> (position(pIndices, t->(t<=c),Reverse=>true)+3,
    10-position(qIndices, t->(t<=r),Reverse=>true),
    c-(select(pIndices, t->(t<=c)))#(-1),
    (select(qIndices, t->(t>r)))#0 - (r+1)
    );

zeroorblank := (m,n,p,q) -> (
	if (m==3 or n==1) then ( " "
		--if (n==1 and q==1 and p==3) then 0 else " "
    	)
	else (
		if (m==4) then (
			if( (n==2 and p==3 and q==2) or (n%2==0 and n>=4 and p==3 and q==0)) then 0 else " "
		)
		else(
		    --if(n==1) then ( " " )if (p==0 and q==1 and (m%2)==0) then 0 else " ")
			--else(
			if (n==2) then (
				if(not m%2==0) then (
					if(p==0 and q==0) then 0 else " "
				)
				else(
					if((p==0 and q==0) or (p==1 and q==2)) then 0 else " "
				)
			)
			else(
				if(n==(m-2) and p==(n+1) and q==(m-2)) then 0
				else(
					if(p<(n-1) and q<(m-4)) then 0
					else (
						if(p==(n-1) and q<=(m-4) and (q-m+4)%2==0) then 0
						else(
       					            if((p-n+1)%2==0 and p<=(n-1) and q==(m-4)) then 0
							else(
								if(n==(m-2) and p==(m+1) and q==(n-2)) then 0
								else " "
							)
						)
					)
				)
			)
		)--)
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

classTab := table(maxq,maxp, (i,j)->rc2mnpq(i,j));
numTab := apply(classTab, i->(apply(i,j->(k:=(j#0,j#1,"H",j#2,j#3,j#3); if(classDat#?k) then (classDat#k)#1 else zeroorblank(j#0,j#1,j#2,j#3)))));

out = tabtocsv(numTab);
"seen.csv" << out << close;
