import { expect, use } from "chai";
import { ethers } from "hardhat";
import { ethers as Ethers } from 'ethers';
import { soliditySha3 } from "web3-utils";

describe("Тестирование смарт-контракта Мастермоста...", function () {

    let masterMost: any;
    let account1: Ethers.Signer; // admin for all contracts
    let account2: Ethers.Signer; // token holder

    before(async function () {
        const [acc1, acc2] = await ethers.getSigners();
        account1 = acc1;
        account2 = acc2;

        const Mastermost = await ethers.getContractFactory("Mastermost");
        masterMost = await Mastermost.deploy();
        console.log("MasterMost address: ", masterMost.address);
        console.log("\n");
    })

    // it("Создание сделки на основе хеша от значимых данных", async function () {
    //     let hash = ethers.utils.formatBytes32String("user");
    //     const setTx = await deal_inst.connect(wallet).initDealByHash(hash);
    //     // ждём когда tx расположится
    //     await setTx.wait();
    //     expect(await deal_inst.getAddrByDealHash(hash)).to.equal(wallet.address);
    // });

    // it("Создание сделки со значимой информацией", async function () {

    //     let _tokenNum = 1000;
    //     let _networkId = ethers.utils.formatBytes32String("masterchain")
    //     let _recipient = await account1.getAddress();

    //     const hash = soliditySha3(
    //         _tokenNum,
    //         _networkId,
    //         _recipient
    //     );

    //     const tx = await deal_inst.connect(wallet).initDealByValue(_tokenNum, _networkId, _recipient);
    //     await tx.wait();
    //     expect(await deal_inst.getAddrByDealHash(hash)).to.equal(wallet.address);
    // });

    it("Добавление валидатора", async function () {
        const tx = await masterMost.connect(account1).addValidator(account1.getAddress());
        await tx.wait();
        expect(await masterMost.isValidator(account1.getAddress())).to.be.equal(true);
    });

    // it("Подтверждение существующей сделки валидатором", async function () {
    //     let _tokenNum = 1000;
    //     let _networkId = ethers.utils.formatBytes32String("masterchain")
    //     let _recipient = await account1.getAddress();
    //     const hash = soliditySha3(
    //         _tokenNum,
    //         _networkId,
    //         _recipient
    //     );
    //     const tx1 = await deal_inst.connect(wallet).initDealByValue(_tokenNum, _networkId, _recipient);
    //     await tx1.wait();
    //     const tx2 = await deal_inst.connect(wallet).confirmDeal(hash);
    //     await tx2.wait();
    //     expect(await deal_inst.getAddrByDealHash(hash)).to.equal(wallet.address);
    // });

    // it("Подтверждение НЕ существующей сделки валидатором", async function () {
    //     let _tokenNum = 1000;
    //     let _networkId = ethers.utils.formatBytes32String("ethereum")
    //     let _recipient = wallet1.address;
    //     const hash = soliditySha3(
    //         _tokenNum,
    //         _networkId,
    //         _recipient
    //     );
    //     await expect(deal_inst.connect(wallet1).confirmDeal(hash)).to.be.reverted;
    // });

    // it("Подтверждение существующей сделки НЕ валидатором", async function () {
    //     let _tokenNum = 1000;
    //     let _networkId = ethers.utils.formatBytes32String("masterchain")
    //     let _recipient = wallet1.address;
    //     const hash = soliditySha3(
    //         _tokenNum,
    //         _networkId,
    //         _recipient
    //     );
    //     const tx1 = await deal_inst.connect(wallet).initDealByValue(_tokenNum, _networkId, _recipient);
    //     await tx1.wait();
    //     await expect(deal_inst.connect(wallet2).confirmDeal(hash)).to.be.reverted;
    // });

    it("УДАЛЕНИЕ единственного валидатора невозможно", async function () {
        await expect(masterMost.connect(account1).deleteValidator(account1.getAddress())).to.be.reverted;;
    });

});
