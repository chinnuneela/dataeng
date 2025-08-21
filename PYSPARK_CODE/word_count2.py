# Mapper 
# Reducer 
from collections import defaultdict

#  hello this is   mukesh   Mukesh  
def mapper(line):

    words = line.strip().lower().split() # [apple tiger ]

    for word in words:
        yield word , 1 



def reducer(mapped_data):

    word_counts = defaultdict(int)
    
    # word_counts = defaultdict(int): 
    # This creates a specialized dictionary. 
    # A defaultdict is a subclass of the built-in dict class. 
    # The key benefit here is that when you try to access a key that doesn't exist, 
    # it automatically creates it with a default value, in this case, int() which is 0. 
    # This saves you from having to check if a key exists before adding to it.

    # We are avoiding these lines     
    #       if word in word_counts:
    #           word_counts[word] += count
    #       else:
    #           word_counts[word] = count
    # By using defaultdict(int), you can write the more concise and cleaner code: word_counts[word] += count.



    for word , count in mapped_data:
        word_counts[word] += count

    return dict(word_counts)



if __name__ == "__main__":

    input_text = ["hello this is a sample ","another sample " , "tiger in my way ","this this this this "]
    
    # Map phase 
    mapped_result = []

    for line in input_text:
        mapped_result.extend(list(mapper(line)))

    print("MAPPED RESULT \n",mapped_result)

    # Reduce phase 
    
    final_counts = reducer(mapped_result)
    print("\n-----------------------------------------")
    print(final_counts)




# Notes 
#yield vs. return

# To understand yield, it helps to compare it to return:

# return: When a function hits a return statement, it exits completely and returns a single value. The next time you call the function, it starts from the beginning.

# yield: When a function hits a yield statement, it "pauses" its execution and sends a value back to the caller. It remembers its state, and the next time you call it (by iterating), it resumes from where it left off.

# Why use yield? 

# In the mapper function, yield is used for memory efficiency. Imagine your input is a text file that is hundreds of gigabytes in size. If mapper were to build a full list of all (word, 1) pairs for the entire file, it would crash your system because it would run out of memory.

# By using yield, the function processes one line at a time and only holds one (word, 1) pair in memory at any given moment. This allows you to process massive datasets that would be impossible to fit into memory otherwise. The reducer can then take these generated pairs and process them efficiently.

# o, for the line "apple tiger", the mapper function doesn't create the list [('apple', 1), ('tiger', 1)]. Instead, it first yields ('apple', 1) and then, when the reducer asks for the next item, it resumes and yields ('tiger', 1).









    









