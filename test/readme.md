for doing quick isolated tests with minimal projects


Eenter this directory

```
cd test
```

You can then do rapid testing e.g.

```
lime test hl

```

And if you need a new test, make a new folder and change porject.xml so it picks up the Main .hx from there. For example this will make the project build `text-scaling/Main.hx`

```xml

<source path="text-scaling" />
```
