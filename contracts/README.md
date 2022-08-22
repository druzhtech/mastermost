# Мастермост

## 

Deal - прикладной СмК описывающий процесс передачи актива из сети источника в сеть назначения
Mastermost - системный СмК принимает сообщения из прикладных СмК и создаёт события для оракула

# Сборка исходников

solc @openzeppelin/=$(pwd)/node_modules/@openzeppelin/ --abi --bin --overwrite -o ../../bridge/data contracts/*.sol
## Сборка

```bash
npm install # yarn
npx hardhat compile # запуск сборки
npx hardhat test # запуск тестов
npx hardhat node & # запуск узла
npx hardhat run scripts/deploy.js --network localhost # развёртывание смарт-контракта в локальной сети

```

