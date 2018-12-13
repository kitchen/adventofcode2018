at least 1000 inches on each side

claim

claims have ids
claims are rectangles with edges parallel to the fabric
left margin
top margin
width
height

```
#123 @ 3,2: 5,4
```

claim ID 123, 3 inches from left edge, 2 inches from right, 5 wide 4 tall

visually: 

```
...........
...........
...#####...
...#####...
...#####...
...#####...
...........
...........
...........
```

they might overlap


first one: find the intersection of all of these


first method: turn each into an array of coordinates that make up the fabric and then union
