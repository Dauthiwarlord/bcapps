(* find errors in curated data for stars, to resolve http://astronomy.stackexchange.com/questions/13126/absolute-apparent-magnitude-and-distance-for-hip31978-inconsistent/13128 *)

stars = AstronomicalData["Star"];

(* find which stars have apparent/absolute magnitude and distance *)

starsapp = Select[stars, NumericQ[AstronomicalData[#, "ApparentMagnitude"]]&];
starsabs = Select[stars, NumericQ[AstronomicalData[#, "AbsoluteMagnitude"]]&];
starsdst = Select[stars, NumericQ[AstronomicalData[#, "DistanceLightYears"]]&];

(* for which do we have two pieces of data, but not the third, a
contradiction since any 2 can compute the third *)

b1=Intersection[Complement[stars,starsdst],Intersection[starsapp,starsabs]];
b2=Intersection[Complement[stars,starsabs],Intersection[starsapp,starsdst]];
b3=Intersection[Complement[stars,starsapp],Intersection[starsabs,starsdst]];

(* for which stars do we have all 3 pieces of data, but they don't "match" *)

starsall = Intersection[starsapp,starsabs,starsdst];

(* light years in a parsec *)
lyp = 32.6156

metric[star_] := AstronomicalData[star, "DistanceLightYears"]/
 Sqrt[10^(2*(AstronomicalData[star, "ApparentMagnitude"]-
 AstronomicalData[star, "AbsoluteMagnitude"])/5)]/lyp

t = Table[{metric[s],s}, {s, starsall}];

t2 = Sort[Transpose[t][[1]]];

ListPlot[t2]

ListPlot[t2,PlotRange->All]

(* based on listplot without plotrange->all, .98 and 1.02 will be the
cutoffs *)

big = Sort[Select[t, #[[1]] > 1.3 &]];

small = Sort[Select[t, #[[1]] < 0.77 &]];



