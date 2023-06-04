println(3 + 5)

a = 4
println(a)

b = (1,2,3,4)
println(b)

for thing = b
    print(thing)
end


for pair in Dict("dog" => "mammal", "cat" => "mammal", "mouse" => "mammal")
    from, to = pair
    println("$from is a $to")
end

function square(a)
    a * a
end

println(square(2))

