const { expect } = require("chai")
const hre = require("hardhat")

describe('Lock', async function () {
    let erc20, Erc20, erc20addr;
    before(async () => {
        Erc20 = await hre.ethers.getContractFactory("ERC20")
        erc20 = await Erc20.deploy('Sekeren Token', 'SEKEREN', 19, 100_000)
        erc20addr = (await erc20.deployed()).address
    })

    if("Cek nama", async function() {
        const Lock = await hre.ethers.getContractFactory("Lock")
        const lock = await Lock.deploy(erc20addr)

        expect(await lock.getName()).to.equal('Anonymous')
        await lock.setName('Salis Keren')
        expect(await lock.getName()).to.equal('Salis Keren')
    })

    it("Saldo harus 0", async function () {
        const Lock = await hre.ethers.getContractFactory("Lock")
        const lock = await Lock.deploy(erc20addr)
        expect(await lock.getBalance()).to.equal(0)
    })

    it("isAcceptorDisabled harus false", async function () {
        const Lock = await hre.ethers.getContractFactory("Lock")
        const lock = await Lock.deploy(erc20addr)
        expect(await lock.isAcceptorDisabled()).to.equal(false)
    })

    it("isUnlockAtBalanceDisabled harus false", async function () {
        const Lock = await hre.ethers.getContractFactory("Lock")
        const lock = await Lock.deploy(erc20addr)
        expect(await lock.isUnlockAtBalanceDisabled()).to.equal(false)
    })

    it("isUnlockAtTimeDisabled harus false", async function () {
        const Lock = await hre.ethers.getContractFactory("Lock")
        const lock = await Lock.deploy(erc20addr)
        expect(await lock.isUnlockAtTimeDisabled()).to.equal(false)
    })

    it('canWithdraw harus false', async function() {
        const Lock = await hre.ethers.getContractFactory("Lock")
        const lock = await Lock.deploy(erc20addr)
        expect(await lock.canWithdraw()).to.equal(false)
    })

    it('cek unlockAtBalance', async function() {
        const Lock = await hre.ethers.getContractFactory("Lock")
        const lock = await Lock.deploy(erc20addr)

        await erc20.approve(lock.address, 1_000)
        await lock.deposit(999)

        expect(await lock.getBalance()).to.equal(999)

        await lock.setTargetBalance(1_000)
        expect(await lock.getTargetBalance()).to.equal(1000)
        expect(await lock.canWithdraw()).to.equal(false)

        await lock.deposit(1)
        expect(await lock.canWithdraw()).to.equal(true)

        await lock.disableUnlockAtBalance()
        expect(await lock.canWithdraw()).to.equal(false)

    })

    it('cek unlockAtAcceptor', async function() {
        const Lock = await hre.ethers.getContractFactory("Lock")
        const lock = await Lock.deploy(erc20addr)
        
        expect(await lock.canWithdraw()).to.equal(false)

        const signer = await hre.ethers.getSigner()
        const signer2 = await hre.ethers.getSigner(2)
        const signer3 = await hre.ethers.getSigner(3)

        const lock2 = await hre.ethers.getContractAt("Lock", lock.address, signer2)

        await lock.setAcceptor(await signer2.getAddress())

        expect(await lock.getAcceptor()).to.equal(await signer2.getAddress())

        await lock2.accept(await signer.getAddress())

        expect(await lock.accepted()).to.equal(true)
        expect(await lock.canWithdraw()).to.equal(true)

        await lock.setAcceptor(await signer3.getAddress())
        expect(await lock.getAcceptor()).to.equal(await signer2.getAddress())

        await lock.disableAcceptor()
        expect(await lock.canWithdraw()).to.equal(false)
    
    })

    // KARENA MASALAH TIMEOUT DAN DELAY. SULIT UNTUK MELAKUKAN TES INI
    // it('cek unlockAtTime', async function() {
    //     const Lock = await hre.ethers.getContractFactory("Lock")
    //     const lock = await Lock.deploy(erc20addr)

        
    //     expect(await lock.canWithdraw()).to.equal(false)

    //     await lock.setTargetTime(Math.floor(Date.now() / 1000) + 20)

    //     expect(await lock.canWithdraw()).to.equal(false)

    //     await new Promise((resolve) => setTimeout(resolve, 30_000))

    //     console.log(await lock.getTimeUnlocked(), await lock.serverTime(), Math.floor(Date.now() / 1000))

    //     expect(await lock.canWithdraw()).to.equal(true)
    
    // })
})