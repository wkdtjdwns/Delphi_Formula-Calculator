unit FormulaCalculator;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, StrUtils;

type
  TForm1 = class(TForm)
    textEdit: TEdit;
    resultBtn: TBitBtn;
    helpText: TLabel;
    procedure resultBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private

    // 중위 -> 후위
    function infixToPostfix(const str: string): TStringList;

    // 후위 표기법 계산 + 연산 과정 기록
    function evaluatePostfix(postfix: TStringList; var steps: TStringList): Double;

  public
  end;

var
  form1: TForm1;

implementation

{$R *.dfm}

{ 연산자 판별 }
function isOperator(c: Char): Boolean;
begin
  Result := c in ['+', '-', '*', '/'];
end;

{ 연산자 우선순위 지정 }
function precedence(op: Char): Integer;

begin

  case op of
    '+', '-': Result := 1;
    '*', '/': Result := 2;
  else
    Result := 0;
  end;

end;

{ 중위 표기법 -> 후위 표기법 변환 }
function TForm1.InfixToPostfix(const str: string): TStringList;

var
  output, stack: TStringList;
  i: Integer;
  token: string;
  c: Char;

begin
  output := TStringList.Create;
  stack := TStringList.Create;

  try
    // 수식 전체 순환
    i := 1;
    while i <= Length(str) do

    begin
      c := str[i];

      { 공백 연산 }
      if c = ' ' then
      begin
        Inc(i); // 다음 문자열로 넘어감 -> 공백 제거
        Continue;
      end;

      { 숫자 또는 소수점 연산 }
      if c in ['0'..'9', '.'] then
      begin
        token := '';  // 토큰 초기화

        // 숫자가 없어질 때까지 숫자나 소수점을 token에 이어 붙임
        while (i <= Length(str)) and (str[i] in ['0'..'9', '.']) do
        begin
          token := token + str[i];
          Inc(i);
        end;

        output.Add(token); // 이어붙인 토큰을 결과에 저장 (숫자 OR 소수점만 존재)
        Continue;
      end

      { 여는 괄호 연산 }
      else if c = '(' then
      begin
        stack.Add(c); // 무조건 스택에 추가
      end

      { 닫는 괄호 연산 }
      else if c = ')' then
      begin

        // 여는 괄호를 만날 때까지
        while (stack.Count > 0) and (stack[stack.Count - 1] <> '(') do
        begin

          // 결과에 집어넣고 스택에선 POP
          output.Add(stack[stack.Count - 1]);
          stack.Delete(stack.Count - 1);

        end;

        // 여는 괄호를 만나면
        if (stack.Count > 0) and (stack[stack.Count - 1] = '(') then
          stack.Delete(stack.Count - 1); // 스택에서 여는 괄호 제거
      end

      { 연산자 연산 }
      else if isOperator(c) then
      begin
        // 우선순위가 높은 연산자부터 실행
        while (stack.Count > 0) and isOperator(stack[stack.Count - 1][1]) and
          (precedence(stack[stack.Count - 1][1]) >= precedence(c)) do
        begin

          // 결과에 더고 스택에선 POP
          output.Add(stack[stack.Count - 1]);
          stack.Delete(stack.Count - 1);

        end;
        stack.Add(c); // 현재 연산자 Push
      end;
      Inc(i);
    end;

    // 스택에 남은 모든 연산자를 결과에 더하고 스택에션 POP
    while stack.Count > 0 do
    begin
      output.Add(stack[stack.Count - 1]);
      stack.Delete(stack.Count - 1);
    end;

    Result := output; // 결과 반환
  finally
    stack.Free; // 스택 메모리 해제
  end;

end;

function TForm1.evaluatePostfix(postfix: TStringList; var steps: TStringList): Double;

type
  PDouble = ^Double; // Double 포인터

var
  stack: TList;
  a, b, r: Double;
  p: PDouble;
  s: string;
  i: Integer;

begin
  stack := TList.Create;
  steps := TStringList.Create;

  try
    // 후위 표기법 수식의 각 토큰을 순서대로 처리
    for i := 0 to postfix.Count - 1 do
    begin
      s := postfix[i];

      { 숫자 연산 }
      if TryStrToFloat(s, r) then
      begin
        New(p);       // 메모리 할당
        p^ := r; //숫자 값 저장
        stack.Add(p); // 스택에 숫자 포인터 추가
      end

      { 연산자 연산 }
      else if isOperator(s[1]) then
      begin
        // 숫자가 2개 미만이면 수식 오류 발생
        if stack.Count < 2 then
          raise Exception.Create('잘못된 수식입니다.');

        // 스택에서 피연산자 b 꺼내기 ("1 + 2" 에서 '2')
        p := stack.Items[stack.Count - 1];
        b := p^;
        Dispose(p); // 메모리 해제
        stack.Delete(stack.Count - 1);

        // 스택에서 피연산자 a 꺼내기 ("1 + 2" 에서 '1')
        p := stack.Items[stack.Count - 1];
        a := p^;
        Dispose(p); // 메모리 해제
        stack.Delete(stack.Count - 1);

        // 연산자에 따라 실제 연산 수행
        case s[1] of
          '+': r := a + b;
          '-': r := a - b;
          '*': r := a * b;

          // 나누기는 예외 처리 ( 0으로 나누기 )
          '/':
            begin
              if b = 0 then raise Exception.Create('0으로 나눌 수 없습니다.');
              r := a / b;
            end;
        end;

        // 연산 과정 기록
        steps.Add(Format('%g %s %g = %g', [a, s, b, r]));

        // 연산 결과를 스택에 다시 추가
        New(p);
        p^ := r;
        stack.Add(p);
      end;
    end;

    // 연산이 끝난 뒤에 스택에 결과가 1개가 아니면 수식 오류
    if stack.Count <> 1 then
      raise Exception.Create('잘못된 수식입니다.');

    // 최종 결과를 꺼내서 반환
    p := stack.Items[0];
    Result := p^;
    Dispose(p);
    stack.Free;

  { 예외 발생 }
  except
    // 스택 안 메모리 해제 및 스택 해제 후 예외를 다시 던짐
    on e: Exception do
    begin
      for i := 0 to stack.Count - 1 do
        Dispose(PDouble(stack.Items[i]));
      stack.Free;
      raise;
    end;
  end;
end;

procedure TForm1.resultBtnClick(Sender: TObject);

var
  str, stepText: string;
  postfix, steps: TStringList;
  resultValue: Double;
  i: Integer;

begin

  str := Trim(textEdit.Text); // 입력창에서 수식 가져오기

  // 수식이 없을 때 예외 처리
  if str = '' then
  begin
    ShowMessage('수식을 입력하세요.');
    Exit;
  end;

  try
    postfix := infixToPostfix(str); // 중위 -> 후위 표기법 변환
    steps := nil;

    try
      resultValue := evaluatePostfix(postfix, steps); // 후위 표기법 계산 및 과정 기록

      // 연산 과정 및 최종 결과 출력 (sLineBreak: 줄바꿈)
      stepText := '연산 과정:' + sLineBreak;
      for i := 0 to steps.Count - 1 do
        stepText := stepText + steps[i] + sLineBreak;

      stepText := stepText + sLineBreak + Format('최종 결과: %g', [resultValue]);

      ShowMessage(stepText);

    // 메모리 해제
    finally
      postfix.Free;
      steps.Free;
    end;

  // 예외 메세지 출력
  except
    on e: Exception do
      ShowMessage('오류: ' + e.Message);
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin

  // 도움말 Text의 내용 변경 (sLineBreak: 줄바꿈)
  helpText.Caption := '이 수식 계산기는 사칙연산을 괄호 포함하여 계산합니다.' + sLineBreak +
                     '사용 가능 연산자: + - * / ()' + sLineBreak +
                     'P.S. 공백은 상관 X';
end;

end.

