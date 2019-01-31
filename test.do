
sysuse auto, clear
sum price
reg mpg trunk
reg price trunk

describe 
test price = 6100

tab price mpg

