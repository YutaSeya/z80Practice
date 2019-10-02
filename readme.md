# Z80勉強用リポジトリ

## 加算
レジスタペア BC,DE,HLで加算が可能
ADD HL,rp
レジスタ HL : (HL) + rp

## 減算
レジスタペア BC,DE,HLで減算が可能
SBC HL,rp
レジスタ HL : (HL) + rp

## 乗算
HL 足し算の結果
DE 掛ける回数
BC 掛け算をする数値

LOOP : HLにBCを足し算をしてに結果を格納
DE-1
DE != 0 : LOOP


