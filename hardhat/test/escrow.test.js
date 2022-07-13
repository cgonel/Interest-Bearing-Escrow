const { expect } = require("chai");

describe("EscrowFactory", () => {
  it("should create a new escrow correctly", async () => {
    const EscrowFactory = await ethers.getContractFactory("EscrowFactory");
    const escrowFactory = await EscrowFactory.deploy();
    const [owner, depositor] = await ethers.getSigners();

    await escrowFactory.createEscrow(
      "0x60a266898e8a298107a5ee4bafbce176a9b9da03",
      10,
      60
    );
    // const newEscrow = escrowFactory.allEscrows(0);
    // expect(newEscrow.depositor()).to.equal(
    //   "0x60a266898e8a298107a5ee4bafbce176a9b9da03"
    // );
  });
});
