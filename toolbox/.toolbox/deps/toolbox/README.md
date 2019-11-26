## Usage

### Sample project

1. Get sample project files:
```
docker run --rm -t -v "$(pwd)":"$(pwd)" -w "$(pwd)" aroq/toolbox sh -c "go-getter github.com/aroq/toolbox//test/tool temp"
```

2. Go into new project directory:
```
cd temp
```

3. Init toolbox:
```
TOOLBOX_INIT="1" make init
```

4. Try commands:
```
bin/test
```

```
K6_HOSTNAME="github.com" bin/k6 --k6-iterations=3
```
