R = (ZZ/3)[x,y,z]

cs = f -> (g:=""; for h in f do g = g|h|"-"; g=substring(g,0,length(g)-1)|".txt"; g)

--search for a "fetch.txt" file
fetchList := new List from {};
if fileExists("fetch.txt") then(
    f := openIn("fetch.txt");
    fetchList = lines get f;
    );

--sanity check on input
for i in fetchList do (if not (isDirectory i) then error("directory " | i | " not found"));

collatedClassDat := new MutableHashTable;

for i in fetchList do (
    filename := "";
    (if fileExists (i|"classDat.txt") then (filename = (i|"classDat.txt")) else(
	    if fileExists (i|"/classDat.txt") then (filename = (i|"/classDat.txt")) else continue));
     collatedClassDat = merge(collatedClassDat, new MutableHashTable from apply(value get filename, (a,b) -> (apply(a, k->if toString class k == "Symbol" then toString k else k), (ideal b#0, b#1))), (a,b) -> (if((length toString net gens a#0) < (length toString net gens b#0)) then a#0 else b#0, a#1+b#1));
     );

printClass = nt -> MatrixExpression (apply (sort pairs collatedClassDat, k -> flatten (toList k#0 | {(k#1)#1} | {net gens ((k#1)#0)})));
toFile = arg -> (if #(sequence arg) == 0 then arg = "data/"; arg|"class.txt" << printClass() << close; arg|"classDat.txt" << apply(pairs collatedClassDat, (x,y) -> (x, (toString gens y#0, y#1)))  << close;);

if (not isDirectory("data/")) then mkdir ("data/");
for i in keys collatedClassDat do(
    for j in fetchList do(
	for k in select( readDirectory j, l->(isDirectory(j|if(j#(-1) == "/") then "" else "/"|l) and l != ".." and l != ".")) do ( 
        fln := j | (if j#(-1) == "/" then "" else "/") | k | "/" | cs(i);
	cmd := "cat \"" | fln | "\" >> \"data/" | cs(i) | "\"";
	if(fileExists fln) then (run cmd);
	)));

toFile();
