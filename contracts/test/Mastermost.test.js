const { expect, use } = require("chai");
const { ethers } = require("hardhat");
const { deployContract, MockProvider, solidity } = require("ethereum-waffle");
const mastermost_json = require('../artifacts/contracts/Mastermost.sol/Mastermost.json');
const deal_json = require('../artifacts/contracts/Deal.sol/Deal.json');

const { soliditySha3 } = require("web3-utils");

use(solidity)

describe("Тестирование смарт-контракта Мастермоста...", function () {

    let mastermost_inst;
    const [wallet, wallet1, wallet2] = new MockProvider().getWallets()

    beforeEach(async () => {
        mastermost_inst = await deployContract(wallet, mastermost_json);
        deal_inst = await deployContract(wallet, deal_json);
    });

    it("Создание сделки на основе хеша от значимых данных", async function () {

        let hash = ethers.utils.formatBytes32String("user");

        const setTx = await deal_inst.connect(wallet).initDealByHash(hash);

        // ждём когда tx расположится
        await setTx.wait();

        expect(await deal_inst.getAddrByDealHash(hash)).to.equal(wallet.address);

    });

    it("Создание сделки со значимой информацией", async function () {

        let _tokenNum = 1000;
        let _networkId = ethers.utils.formatBytes32String("masterchain")
        let _recipient = wallet1.address;

        const hash = soliditySha3(
            _tokenNum,
            _networkId,
            _recipient
        );

        const tx = await deal_inst.connect(wallet).initDealByValue(_tokenNum, _networkId, _recipient);

        // ждём когда tx расположится
        await tx.wait();

        expect(await deal_inst.getAddrByDealHash(hash)).to.equal(wallet.address);

    });

    it("Добавление валидатора", async function () {

        const tx = await mastermost_inst.connect(wallet).addValidator(wallet1.address);
        await tx.wait();

        expect(await mastermost_inst.isValidator(wallet1.address)).to.be.equal(true);

    });

    it("Подтверждение существующей сделки валидатором", async function () {

        let _tokenNum = 1000;
        let _networkId = ethers.utils.formatBytes32String("masterchain")
        let _recipient = wallet1.address;

        const hash = soliditySha3(
            _tokenNum,
            _networkId,
            _recipient
        );

        const tx1 = await deal_inst.connect(wallet).initDealByValue(_tokenNum, _networkId, _recipient);
        await tx1.wait();

        const tx2 = await deal_inst.connect(wallet).confirmDeal(hash);
        await tx2.wait();

        expect(await deal_inst.getAddrByDealHash(hash)).to.equal(wallet.address);

    });

    it("Подтверждение НЕ существующей сделки валидатором", async function () {

        let _tokenNum = 1000;
        let _networkId = ethers.utils.formatBytes32String("ethereum")
        let _recipient = wallet1.address;

        const hash = soliditySha3(
            _tokenNum,
            _networkId,
            _recipient
        );

        await expect(deal_inst.connect(wallet1).confirmDeal(hash)).to.be.reverted;

    });

    it("Подтверждение существующей сделки НЕ валидатором", async function () {

        let _tokenNum = 1000;
        let _networkId = ethers.utils.formatBytes32String("masterchain")
        let _recipient = wallet1.address;

        const hash = soliditySha3(
            _tokenNum,
            _networkId,
            _recipient
        );

        const tx1 = await deal_inst.connect(wallet).initDealByValue(_tokenNum, _networkId, _recipient);
        await tx1.wait();

        await expect(deal_inst.connect(wallet2).confirmDeal(hash)).to.be.reverted;

    });

    it("УДАЛЕНИЕ единственного валидатора невозможно", async function () {

        await expect(mastermost_inst.connect(wallet).deleteValidator(wallet.address)).to.be.reverted;;

    });

});
