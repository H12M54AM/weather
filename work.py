restart = True # variable to make it restart
def start() : #start pos to return to
#Pizza time!
   ingredients = ['Mozzerala', 'basil', 'tomato', 'garlic', 'olive oil']
   print(ingredients)
   #above is the base pizza, below is where you add extra ingredients 
   extra = (input("input extra ingredients here;"))
   print(ingredients, "with addional", extra)
   ingredients.append(extra)
   print(ingredients)
   rem = (input("input undesired ingredients here;"))
   print(ingredients, "without", rem)
   ingredients.remove(rem)
   print(ingredients)
   final = input('is this correct?') #confirmation check
   if final == ('yes') or ('y') or ("confirm") or ("Yes"):
      restart = False 
      print("Thank you for your order, your pizza of ", ingredients, "is being prepared") #will no longer loop as restart is false
   elif final == ("no") or ("No") or ("Wrong"):
      print("Sorry, Restarting order")
   else: 
      print('Restarting order')
      
while restart == True: # this will loop until restart is set to be False
   start()