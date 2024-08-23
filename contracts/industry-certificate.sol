// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract IndustryCertification {

    // Structure to store certificate details
    struct Certificate {
        uint id;
        string studentName;
        string courseName;
        string issuer;
        address issuerAddress;
        uint issueDate;
        string status; // Status of the certificate (e.g., "Issued", "Verified", "Revoked")
    }

    // Structure to store industry partner details
    struct IndustryPartner {
        uint id;
        string name;
        address partnerAddress;
        bool isActive;
    }

    // Mapping from certificate ID to certificate details
    mapping(uint => Certificate) public certificates;

    // Mapping from industry partner ID to partner details
    mapping(uint => IndustryPartner) public industryPartners;

    // Counters for certificates and partners
    uint public certificatesCount;
    uint public partnersCount;

    // Address of the contract owner (e.g., the organization)
    address public owner;

    // Modifier to restrict access to only the owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    // Modifier to restrict access to only active industry partners
    modifier onlyActivePartner() {
        require(isActivePartner(msg.sender), "Not an active partner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // Function to add a new industry partner
    function addIndustryPartner(string memory name, address partnerAddress) public onlyOwner {
        partnersCount++;
        industryPartners[partnersCount] = IndustryPartner(partnersCount, name, partnerAddress, true);
    }

    // Function to issue a new certificate
    function issueCertificate(
        string memory studentName,
        string memory courseName,
        string memory issuer
    ) public onlyOwner {
        certificatesCount++;
        certificates[certificatesCount] = Certificate(
            certificatesCount,
            studentName,
            courseName,
            issuer,
            msg.sender,
            block.timestamp,
            "Issued"
        );
    }

    // Function to verify a certificate by an industry partner
    function verifyCertificate(uint certificateId) public onlyActivePartner {
        require(certificateId > 0 && certificateId <= certificatesCount, "Invalid certificate ID");
        Certificate storage cert = certificates[certificateId];
        require(keccak256(bytes(cert.status)) == keccak256(bytes("Issued")), "Certificate not valid for verification");

        cert.status = "Verified";
    }

    // Function to revoke a certificate by the issuer
    function revokeCertificate(uint certificateId) public onlyOwner {
        require(certificateId > 0 && certificateId <= certificatesCount, "Invalid certificate ID");
        Certificate storage cert = certificates[certificateId];
        require(keccak256(bytes(cert.status)) == keccak256(bytes("Issued")), "Certificate not valid for revocation");

        cert.status = "Revoked";
    }

    // Function to check if an address is an active industry partner
    function isActivePartner(address partnerAddress) public view returns (bool) {
        for (uint i = 1; i <= partnersCount; i++) {
            if (industryPartners[i].partnerAddress == partnerAddress && industryPartners[i].isActive) {
                return true;
            }
        }
        return false;
    }

    // Function to deactivate an industry partner
    function deactivatePartner(uint partnerId) public onlyOwner {
        require(partnerId > 0 && partnerId <= partnersCount, "Invalid partner ID");
        industryPartners[partnerId].isActive = false;
    }

    // Function to reactivate an industry partner
    function reactivatePartner(uint partnerId) public onlyOwner {
        require(partnerId > 0 && partnerId <= partnersCount, "Invalid partner ID");
        industryPartners[partnerId].isActive = true;
    }

    // Function to view certificate details
    function viewCertificate(uint certificateId) public view returns (
        uint,
        string memory,
        string memory,
        string memory,
        address,
        uint,
        string memory
    ) {
        require(certificateId > 0 && certificateId <= certificatesCount, "Invalid certificate ID");
        Certificate memory cert = certificates[certificateId];
        return (
            cert.id,
            cert.studentName,
            cert.courseName,
            cert.issuer,
            cert.issuerAddress,
            cert.issueDate,
            cert.status
        );
    }
}
