import pyspark


lines = [(Hello ,1),today, is, Friday, Friday, is ,beautiful ,then, Monday, MOnday, is ,salary ,day]

lines = [
        "Hello today is Friday",1 ,     [hello,today,is , friday]
        "Friday is beautiful then Monday",1,
        "MOnday is salary day"
]

print(len(lines))

lines.flatMap(lambda line:str: line.split())
#   Take every element of the list lines and apply the function to that 

reduceByKey : Aggregates the counts for each word 

tel : hyd  
tel : hyd 