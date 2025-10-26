const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("ChainVertex Project Contract", () => {
  let project;
  let owner;
  let user1;

  beforeEach(async () => {
    [owner, user1] = await ethers.getSigners();
    const Project = await ethers.getContractFactory("Project");
    project = await Project.deploy();
    await project.waitForDeployment();
  });

  describe("Vertex Operations", () => {
    it("Should create a vertex successfully", async () => {
      const tx = await project.createVertex("Test Vertex");
      const receipt = await tx.wait();
      
      const vertex = await project.getVertex(0);
      expect(vertex.data).to.equal("Test Vertex");
      expect(vertex.owner).to.equal(owner.address);
    });

    it("Should increment vertex counter", async () => {
      await project.createVertex("Vertex 1");
      await project.createVertex("Vertex 2");
      
      const total = await project.getTotalVertices();
      expect(total).to.equal(2);
    });

    it("Should revert on empty data", async () => {
      await expect(project.createVertex("")).to.be.revertedWith(
        "ChainVertex: Data cannot be empty"
      );
    });
  });

  describe("Edge Operations", () => {
    beforeEach(async () => {
      await project.createVertex("Vertex 1");
      await project.createVertex("Vertex 2");
    });

    it("Should create an edge successfully", async () => {
      await project.createEdge(0, 1, 100, "connection");
      
      const edge = await project.getEdge(0, 1);
      expect(edge.weight).to.equal(100);
      expect(edge.edgeType).to.equal("connection");
    });

    it("Should prevent self-loops", async () => {
      await expect(project.createEdge(0, 0, 100, "self")).to.be.revertedWith(
        "ChainVertex: Cannot create self-loops"
      );
    });
  });

  describe("Query Operations", () => {
    beforeEach(async () => {
      await project.createVertex("Vertex 1");
      await project.createVertex("Vertex 2");
      await project.createEdge(0, 1, 50, "linked");
    });

    it("Should retrieve adjacent vertices", async () => {
      const adjacent = await project.getAdjacentVertices(0);
      expect(adjacent.length).to.equal(1);
      expect(adjacent[0]).to.equal(1);
    });

    it("Should get user vertices", async () => {
      const userVerts = await project.getUserVertices(owner.address);
      expect(userVerts.length).to.equal(2);
    });
  });
});