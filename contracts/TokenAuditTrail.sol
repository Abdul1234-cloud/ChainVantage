// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title Project
 * @dev ChainVertex - Decentralized Data Vertex Management System
 * @notice This contract enables creation and management of interconnected data vertices on the blockchain
 * @author ChainVertex Team
 */

contract Project {
    
    // ==================== DATA STRUCTURES ====================
    
    /**
     * @dev Struct representing a data vertex in the graph
     */
    struct Vertex {
        uint256 vertexId;           // Unique identifier for the vertex
        address owner;              // Address of the vertex owner
        string data;                // Metadata associated with the vertex
        uint256 createdAt;          // Timestamp when vertex was created
        bool exists;                // Boolean flag indicating if vertex exists
    }
    
    /**
     * @dev Struct representing a connection between two vertices
     */
    struct Edge {
        uint256 fromVertex;         // Source vertex ID
        uint256 toVertex;           // Destination vertex ID
        uint256 weight;             // Weight/strength of the connection
        string edgeType;            // Type of relationship
        bool exists;                // Boolean flag indicating if edge exists
    }
    
    // ==================== STATE VARIABLES ====================
    
    mapping(uint256 => Vertex) public vertices;
    mapping(uint256 => mapping(uint256 => Edge)) public edges;
    mapping(address => uint256[]) public userVertices;
    mapping(uint256 => uint256[]) public adjacentVertices;
    
    uint256 public vertexCounter = 0;
    uint256 public edgeCounter = 0;
    address public contractOwner;
    
    // ==================== EVENTS ====================
    
    event VertexCreated(
        uint256 indexed vertexId,
        address indexed owner,
        string data,
        uint256 timestamp
    );
    
    event EdgeCreated(
        uint256 indexed fromVertex,
        uint256 indexed toVertex,
        uint256 weight,
        string edgeType
    );
    
    event VertexDeleted(uint256 indexed vertexId, address indexed owner);
    event EdgeDeleted(uint256 indexed fromVertex, uint256 indexed toVertex);
    
    // ==================== MODIFIERS ====================
    
    /**
     * @dev Modifier to restrict function calls to the owner of a specific vertex
     */
    modifier onlyVertexOwner(uint256 _vertexId) {
        require(
            vertices[_vertexId].owner == msg.sender,
            "ChainVertex: Only vertex owner can perform this action"
        );
        _;
    }
    
    /**
     * @dev Modifier to verify that a vertex exists
     */
    modifier vertexExists(uint256 _vertexId) {
        require(vertices[_vertexId].exists, "ChainVertex: Vertex does not exist");
        _;
    }
    
    // ==================== CONSTRUCTOR ====================
    
    /**
     * @dev Initialize the contract and set the deployer as contract owner
     */
    constructor() {
        contractOwner = msg.sender;
    }
    
    // ==================== CORE FUNCTIONS ====================
    
    /**
     * @dev Create a new vertex in the graph
     * @param _data The metadata associated with the vertex
     * @return vertexId The ID of the newly created vertex
     * 
     * Requirements:
     * - Data cannot be empty
     * - Data must not exceed 500 characters
     * 
     * Emits a {VertexCreated} event
     */
    function createVertex(string memory _data) public returns (uint256) {
        require(bytes(_data).length > 0, "ChainVertex: Data cannot be empty");
        require(bytes(_data).length <= 500, "ChainVertex: Data exceeds maximum length");
        
        uint256 newVertexId = vertexCounter++;
        
        vertices[newVertexId] = Vertex({
            vertexId: newVertexId,
            owner: msg.sender,
            data: _data,
            createdAt: block.timestamp,
            exists: true
        });
        
        userVertices[msg.sender].push(newVertexId);
        
        emit VertexCreated(newVertexId, msg.sender, _data, block.timestamp);
        
        return newVertexId;
    }
    
    /**
     * @dev Create an edge (connection) between two vertices
     * @param _fromVertex ID of the source vertex
     * @param _toVertex ID of the destination vertex
     * @param _weight The weight/strength of the connection (must be > 0)
     * @param _edgeType Description of the relationship type
     * 
     * Requirements:
     * - Both vertices must exist
     * - Weight must be greater than zero
     * - Edge type cannot be empty
     * - Cannot create self-loops
     * - Edge should not already exist between these vertices
     * 
     * Emits an {EdgeCreated} event
     */
    function createEdge(
        uint256 _fromVertex,
        uint256 _toVertex,
        uint256 _weight,
        string memory _edgeType
    ) public vertexExists(_fromVertex) vertexExists(_toVertex) {
        require(_weight > 0, "ChainVertex: Weight must be greater than zero");
        require(bytes(_edgeType).length > 0, "ChainVertex: Edge type cannot be empty");
        require(_fromVertex != _toVertex, "ChainVertex: Cannot create self-loops");
        require(!edges[_fromVertex][_toVertex].exists, "ChainVertex: Edge already exists");
        
        edges[_fromVertex][_toVertex] = Edge({
            fromVertex: _fromVertex,
            toVertex: _toVertex,
            weight: _weight,
            edgeType: _edgeType,
            exists: true
        });
        
        adjacentVertices[_fromVertex].push(_toVertex);
        edgeCounter++;
        
        emit EdgeCreated(_fromVertex, _toVertex, _weight, _edgeType);
    }
    
    /**
     * @dev Query vertex information
     * @param _vertexId The ID of the vertex to query
     * @return The Vertex struct containing all vertex information
     * 
     * Requirements:
     * - Vertex must exist
     */
    function getVertex(uint256 _vertexId)
        public
        view
        vertexExists(_vertexId)
        returns (Vertex memory)
    {
        return vertices[_vertexId];
    }
    
    // ==================== UTILITY FUNCTIONS ====================
    
    /**
     * @dev Get all adjacent vertices connected to a given vertex
     * @param _vertexId The ID of the vertex
     * @return Array of adjacent vertex IDs
     * 
     * Requirements:
     * - Vertex must exist
     */
    function getAdjacentVertices(uint256 _vertexId)
        public
        view
        vertexExists(_vertexId)
        returns (uint256[] memory)
    {
        return adjacentVertices[_vertexId];
    }
    
    /**
     * @dev Get edge information between two vertices
     * @param _fromVertex Source vertex ID
     * @param _toVertex Destination vertex ID
     * @return The Edge struct containing all edge information
     * 
     * Requirements:
     * - Edge must exist between the two vertices
     */
    function getEdge(uint256 _fromVertex, uint256 _toVertex)
        public
        view
        returns (Edge memory)
    {
        require(edges[_fromVertex][_toVertex].exists, "ChainVertex: Edge does not exist");
        return edges[_fromVertex][_toVertex];
    }
    
    /**
     * @dev Get all vertices created by a specific user
     * @param _user The address of the user
     * @return Array of vertex IDs owned by the user
     */
    function getUserVertices(address _user)
        public
        view
        returns (uint256[] memory)
    {
        return userVertices[_user];
    }
    
    /**
     * @dev Get the total number of vertices in the graph
     * @return The count of all vertices
     */
    function getTotalVertices() public view returns (uint256) {
        return vertexCounter;
    }
    
    /**
     * @dev Get the total number of edges in the graph
     * @return The count of all edges
     */
    function getTotalEdges() public view returns (uint256) {
        return edgeCounter;
    }
    
    /**
     * @dev Delete a vertex (only owner can delete)
     * @param _vertexId The ID of the vertex to delete
     * 
     * Requirements:
     * - Caller must be the vertex owner
     * - Vertex must exist
     * 
     * Emits a {VertexDeleted} event
     */
    function deleteVertex(uint256 _vertexId)
        public
        onlyVertexOwner(_vertexId)
        vertexExists(_vertexId)
    {
        vertices[_vertexId].exists = false;
        emit VertexDeleted(_vertexId, msg.sender);
    }
    
    /**
     * @dev Check if a vertex exists
     * @param _vertexId The ID of the vertex to check
     * @return Boolean indicating if vertex exists
     */
    function isVertexExists(uint256 _vertexId) public view returns (bool) {
        return vertices[_vertexId].exists;
    }
}