#Given  lines of input, print the  character from each line as a new line of output. #It is guaranteed that each of the  lines of input will have a  character.
#Hello
#World
#how are you
#Sample Output
#
#l
#r
#w

cut -c3
################################
Display the 2nd and 7th character from each line of text.
Sample Input
Hello
World
how are you

Sample Output
e
o
oe

cut -c2,7
################################
Sample Input

Hello
World
how are you
Sample Output

ello
orld
ow are

cut -c2-7
################################
Display the first four characters from each line of text.

Sample Input
Hello
World
how are you

Sample Output
Hell
Worl
how 

cut -c1-4
################################
Given a tab delimited file with several columns (tsv format) print the first three fields.

Sample Input
1   New York, New York[10]  8,244,910   1   New York-Northern New Jersey-Long Island, NY-NJ-PA MSA  19,015,900  1   New York-Newark-Bridgeport, NY-NJ-CT-PA CSA 22,214,083
2   Los Angeles, California 3,819,702   2   Los Angeles-Long Beach-Santa Ana, CA MSA    12,944,801  2   Los Angeles-Long Beach-Riverside, CA CSA    18,081,569
3   Chicago, Illinois   2,707,120   3   Chicago-Joliet-Naperville, IL-IN-WI MSA 9,504,753   3   Chicago-Naperville-Michigan City, IL-IN-WI CSA  9,729,825
4   Houston, Texas  2,145,146   4   Dallas-Fort Worth-Arlington, TX MSA 6,526,548   4   Washington-Baltimore-Northern Virginia, DC-MD-VA-WV CSA 8,718,083
5   Philadelphia, Pennsylvania[11]  1,536,471   5   Houston-Sugar Land-Baytown, TX MSA  6,086,538   5   Boston-Worcester-Manchester, MA-RI-NH CSA   7,601,061

Sample Output
1   New York, New York[10]  8,244,910
2   Los Angeles, California 3,819,702
3   Chicago, Illinois   2,707,120
4   Houston, Texas  2,145,146
5   Philadelphia, Pennsylvania[11]  1,536,471

cut -f -3
################################
Print the characters from thirteenth position to the end.

Sample Input

New York is a state in the Northeastern and Mid-Atlantic regions of the United States. 
New York is the 27th-most extensive, the third-most populous populated of the 50 United States. 
New York is bordered by New Jersey and Pennsylvania to the south.
About one third of all the battles of the Revolutionary War took place in New York.
Henry Hudson's 1609 voyage marked the beginning of European involvement with the area.
Sample Output

a state in the Northeastern and Mid-Atlantic regions of the United States. 
the 27th-most extensive, the third-most populous populated of the 50 United States. 
bordered by New Jersey and Pennsylvania to the south.
ird of all the battles of the Revolutionary War took place in New York.
's 1609 voyage marked the beginning of European involvement with the area.

cut -c13-
################################
Given a sentence, identify and display its fourth word. Assume that the space (' ') is the only delimiter between words.
Sample Input

Hello
World
how are you
Sample Output

Hello
World

cut -d' ' -f4
################################
Given a sentence, identify and display its first three words. Assume that the space (' ') is the only delimiter between words.

Sample Input
New York is a state in the Northeastern and Mid-Atlantic regions of the United States. 
New York is the 27th-most extensive, the third-most populous populated of the 50 United States. 
New York is bordered by New Jersey and Pennsylvania to the south.
About one third of all the battles of the Revolutionary War took place in New York.
Henry Hudson's 1609 voyage marked the beginning of European involvement with the area.

Sample Output
New York is
New York is
New York is
About one third
Henry Hudson's 1609

cut -d" " -f1-3
################################
Given a tab delimited file with several columns (tsv format) print the fields from second fields to last field.

Sample Input
1   New York, New York[10]  8,244,910   1   New York-Northern New Jersey-Long Island, NY-NJ-PA MSA  19,015,900  1   New York-Newark-Bridgeport, NY-NJ-CT-PA CSA 22,214,083
2   Los Angeles, California 3,819,702   2   Los Angeles-Long Beach-Santa Ana, CA MSA    12,944,801  2   Los Angeles-Long Beach-Riverside, CA CSA    18,081,569
3   Chicago, Illinois   2,707,120   3   Chicago-Joliet-Naperville, IL-IN-WI MSA 9,504,753   3   Chicago-Naperville-Michigan City, IL-IN-WI CSA  9,729,825
4   Houston, Texas  2,145,146   4   Dallas-Fort Worth-Arlington, TX MSA 6,526,548   4   Washington-Baltimore-Northern Virginia, DC-MD-VA-WV CSA 8,718,083
5   Philadelphia, Pennsylvania[11]  1,536,471   5   Houston-Sugar Land-Baytown, TX MSA  6,086,538   5   Boston-Worcester-Manchester, MA-RI-NH CSA   7,601,061

Sample Output
New York, New York[10]  8,244,910   1   New York-Northern New Jersey-Long Island, NY-NJ-PA MSA  19,015,900  1   New York-Newark-Bridgeport, NY-NJ-CT-PA CSA 22,214,083
Los Angeles, California 3,819,702   2   Los Angeles-Long Beach-Santa Ana, CA MSA    12,944,801  2   Los Angeles-Long Beach-Riverside, CA CSA    18,081,569
Chicago, Illinois   2,707,120   3   Chicago-Joliet-Naperville, IL-IN-WI MSA 9,504,753   3   Chicago-Naperville-Michigan City, IL-IN-WI CSA  9,729,825
Houston, Texas  2,145,146   4   Dallas-Fort Worth-Arlington, TX MSA 6,526,548   4   Washington-Baltimore-Northern Virginia, DC-MD-VA-WV CSA 8,718,083
Philadelphia, Pennsylvania[11]  1,536,471   5   Houston-Sugar Land-Baytown, TX MSA  6,086,538   5   Boston-Worcester-Manchester, MA-RI-NH CSA   7,601,061

cut -d$'\t' -f2-
################################
Display first 20 lines
head -n20
################################
Display last 20 lines
tail -n20
################################
Display the first twenty characters of a file
head -c20
################################
Display the lines (from line number 12 to 22, both inclusive) of a given text file.
head -n 22 | tail -11
################################
Display the last 20 characters
taif -c 20
################################

################################
################################
################################
################################
################################
################################
################################



