pragma solidity >=0.7.0 <0.9.0;

contract Upload {
    
    struct Access {
        address user;
        bool access;
    }
    
    struct User {
        string username;
        string password;
        bool registered;
    }
    
    mapping(address => User) public users;
    mapping(address => string[]) value;
    mapping(address => mapping(address => bool)) ownership;
    mapping(address => Access[]) accessList;
    mapping(address => mapping(address => bool)) previousData;
    
    function registerUser(string memory username, string memory password) external {
        require(!users[msg.sender].registered, "User already registered");
        users[msg.sender] = User(username, password, true);
    }
    
   function authenticate(string memory username, string memory password) public returns (bool) {
    for (uint i = 0; i < msg.sender.balance; i++) {
        if (keccak256(abi.encodePacked(users[msg.sender].username)) == keccak256(abi.encodePacked(username)) &&
            keccak256(abi.encodePacked(users[msg.sender].password)) == keccak256(abi.encodePacked(password))) {
            return true;
        }
    }
    users[msg.sender].registered = false; // Remove registration if username or password is incorrect
    return false;
}

    
    function add(address _user,string memory url) external {
        require(users[msg.sender].registered, "User not registered");
        value[_user].push(url);
    }
    
    function allow(address user) external {
        require(users[msg.sender].registered, "User not registered");
        ownership[msg.sender][user] = true;
        if (previousData[msg.sender][user]) {
            for (uint i = 0; i < accessList[msg.sender].length; i++) {
                if (accessList[msg.sender][i].user == user) {
                    accessList[msg.sender][i].access = true;
                }
            }
        } else {
            accessList[msg.sender].push(Access(user, true));
            previousData[msg.sender][user] = true;
        }
    }
    
    function disallow(address user) public {
        require(users[msg.sender].registered, "User not registered");
        ownership[msg.sender][user] = false;
        for (uint i = 0; i < accessList[msg.sender].length; i++) {
            if (accessList[msg.sender][i].user == user) {
                accessList[msg.sender][i].access = false;
            }
        }
    }
    
    function display(address _user) external returns (string[] memory) {
        require(users[msg.sender].registered, "User not registered");
        require(authenticate(users[msg.sender].username, users[msg.sender].password), "Invalid username or password");
        require(_user == msg.sender || ownership[_user][msg.sender], "You don't have access");
        return value[_user];
    }
    
    function shareAccess() public returns (Access[] memory) {
        require(users[msg.sender].registered, "User not registered");
        require(authenticate(users[msg.sender].username, users[msg.sender].password), "Invalid username or password");
        return accessList[msg.sender];
    }
    
}
