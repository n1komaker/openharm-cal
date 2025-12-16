@Entry
@Component
struct Index {
  @State expression: string = '';
  @State resultPreview: string = '';

  private buttons: string[] = [
    'sin', 'cos', 'AC', 'DEL', '÷',
    'x²', '√', '7', '8', '9',
    'log', '×', '4', '5', '6',
    '1/x', '-', '1', '2', '3',
    '%', '+', '0', '.', '='
  ];

  isOperator(char: string): boolean {
    return ['+', '-', '×', '÷'].includes(char);
  }

  getLastNumberIndex(expr: string): number {
    let i = expr.length - 1;
    while (i >= 0) {
      if (this.isOperator(expr[i])) {
        return i + 1;
      }
      i--;
    }
    return 0;
  }

  calculateExpression(expr: string): string {
    if (!expr) return '';

    let tempExpr = expr.replace(/×/g, '*').replace(/÷/g, '/');
    if (this.isOperator(tempExpr.slice(-1))) {
      tempExpr = tempExpr.slice(0, -1);
    }

    try {
      let tokens: (number | string)[] = [];
      let currentNum = '';

      for (let i = 0; i < tempExpr.length; i++) {
        let char = tempExpr[i];
        if (['+', '-', '*', '/'].includes(char)) {
          if (currentNum !== '') {
            tokens.push(parseFloat(currentNum));
            currentNum = '';
          }
          tokens.push(char);
        } else {
          currentNum += char;
        }
      }
      if (currentNum !== '') {
        tokens.push(parseFloat(currentNum));
      }

      let i = 0;
      while (i < tokens.length) {
        if (tokens[i] === '*' || tokens[i] === '/') {
          let prev = tokens[i - 1] as number;
          let next = tokens[i + 1] as number;
          let res = tokens[i] === '*' ? prev * next : prev / next;
          tokens.splice(i - 1, 3, res);
          i--;
        }
        i++;
      }

      let result = tokens[0] as number;
      for (let j = 1; j < tokens.length; j += 2) {
        let op = tokens[j];
        let val = tokens[j + 1] as number;
        if (op === '+') result += val;
        if (op === '-') result -= val;
      }

      if (isNaN(result) || !isFinite(result)) return 'Error';
      return String(parseFloat(result.toFixed(8)));
    } catch (e) {
      return 'Error';
    }
  }

  onButtonClick(btn: string) {
    if (btn === 'AC') {
      this.expression = '';
      this.resultPreview = '';
      return;
    }

    if (btn === 'DEL') {
      this.expression = this.expression.slice(0, -1);
      return;
    }

    if (btn === '=') {
      let res = this.calculateExpression(this.expression);
      this.expression = res;
      this.resultPreview = '';
      return;
    }

    if (['sin', 'cos', 'x²', '√', 'log', '1/x', '%'].includes(btn)) {
      let lastIdx = this.getLastNumberIndex(this.expression);
      let numStr = this.expression.substring(lastIdx);

      if (numStr === '' || numStr === '.') return;

      let val = parseFloat(numStr);
      let newVal = 0;

      switch (btn) {
        case 'sin': newVal = Math.sin(val * Math.PI / 180); break;
        case 'cos': newVal = Math.cos(val * Math.PI / 180); break;
        case 'x²': newVal = Math.pow(val, 2); break;
        case '√': newVal = Math.sqrt(val); break;
        case 'log': newVal = Math.log10(val); break;
        case '1/x': newVal = 1 / val; break;
        case '%': newVal = val / 100; break;
      }

      let formattedVal = parseFloat(newVal.toFixed(8)).toString();
      this.expression = this.expression.substring(0, lastIdx) + formattedVal;
      return;
    }

    if (this.isOperator(btn)) {
      if (this.expression === '' || this.isOperator(this.expression.slice(-1))) {
        if (this.expression !== '') {
          this.expression = this.expression.slice(0, -1) + btn;
        }
      } else {
        this.expression += btn;
      }
      return;
    }

    this.expression += btn;
  }

  getBtnColor(btn: string): ResourceColor {
    if (['AC', 'DEL'].includes(btn)) return '#A5A5A5';
    if (['=', '+', '-', '×', '÷'].includes(btn)) return '#FF9F0A';
    if (['sin', 'cos', 'x²', '√', 'log', '1/x', '%'].includes(btn)) return '#424242';
    return '#333333';
  }

  getBtnFontSize(btn: string): number {
    if (['sin', 'cos', 'log', '1/x', 'AC', 'DEL'].includes(btn)) return 20;
    return 30;
  }

  build() {
    Column() {
      Column() {
        Text(this.expression)
          .fontColor(Color.White)
          .fontSize(this.expression.length > 10 ? 40 : 60)
          .fontWeight(FontWeight.Regular)
          .textAlign(TextAlign.End)
          .width('100%')
          .padding({ right: 20 })
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.None })
      }
      .width('100%')
      .height('30%')
      .justifyContent(FlexAlign.End)
      .padding({ bottom: 10 })

      Grid() {
        ForEach(this.buttons, (btn: string) => {
          GridItem() {
            Button(btn)
              .type(ButtonType.Normal)
              .borderRadius(12)
              .backgroundColor(this.getBtnColor(btn))
              .fontColor(btn === 'AC' || btn === 'DEL' ? Color.Black : Color.White)
              .fontSize(this.getBtnFontSize(btn))
              .width('100%')
              .height('100%')
              .onClick(() => this.onButtonClick(btn))
          }
        })
      }
      .columnsTemplate('1fr 1fr 1fr 1fr 1fr')
      .rowsTemplate('1fr 1fr 1fr 1fr 1fr')
      .columnsGap(8)
      .rowsGap(8)
      .width('100%')
      .height('70%')
      .padding(10)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#000000')
  }
}