# simple word count 

def count_words(text):

    words = text.split()

    return len(words)



if __name__ == "__main__":
    
    text = "Hello this is mukesh "
    print(count_words(text))



