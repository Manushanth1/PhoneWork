import 'package:flutter/material.dart';

class KYCScreen extends StatefulWidget {
  final bool isWorkerMode;

  const KYCScreen({super.key, required this.isWorkerMode});

  @override
  State<KYCScreen> createState() => _KYCScreenState();
}

class _KYCScreenState extends State<KYCScreen> {
  int _currentStep = 0;
  bool _phoneVerified = false;
  bool _aadhaarUploaded = false;
  bool _panUploaded = false;
  bool _licenseUploaded = false;
  bool _bankVerified = false;
  bool _skillProofUploaded = false;
  bool _selfieTaken = false;

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _accountNoController = TextEditingController();
  final TextEditingController _ifscController = TextEditingController();
  final TextEditingController _holderNameController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _accountNoController.dispose();
    _ifscController.dispose();
    _holderNameController.dispose();
    super.dispose();
  }

  // Mock file picking
  void _uploadFile(String type) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Simulating $type upload...')));
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        if (type == 'Aadhaar') _aadhaarUploaded = true;
        if (type == 'PAN') _panUploaded = true;
        if (type == 'Driving License') _licenseUploaded = true;
        if (type == 'Skill Proof') _skillProofUploaded = true;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$type uploaded successfully!')));
    });
  }

  void _verifyPhone() {
    if (_phoneController.text.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 10-digit number')),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Enter OTP"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("OTP sent to your phone"),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: "Enter 1234"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (_otpController.text == "1234") {
                setState(() {
                  _phoneVerified = true;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Phone Verified!')),
                );
              } else {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Invalid OTP')));
              }
            },
            child: const Text("Verify"),
          ),
        ],
      ),
    );
  }

  void _verifyBank() {
    if (_accountNoController.text.isEmpty ||
        _ifscController.text.isEmpty ||
        _holderNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all bank details')),
      );
      return;
    }
    // Mock verification
    setState(() {
      _bankVerified = true;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Bank Details Verified!')));
  }

  void _takeSelfie() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Opening camera...')));
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        _selfieTaken = true;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Selfie verified!')));
    });
  }

  List<Step> _getSteps() {
    return [
      // Step 1: Phone Verification
      Step(
        title: const Text("Phone Verification"),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Verify your phone number to proceed"),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: "Phone Number",
                      border: OutlineInputBorder(),
                      prefixText: "+91 ",
                    ),
                    enabled: !_phoneVerified,
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _phoneVerified ? null : _verifyPhone,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _phoneVerified
                        ? Colors.green
                        : Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(_phoneVerified ? "Verified" : "Send OTP"),
                ),
              ],
            ),
          ],
        ),
        isActive: _currentStep >= 0,
        state: _phoneVerified ? StepState.complete : StepState.indexed,
      ),

      // Step 2: Identity Verification (Aadhaar, PAN, License)
      Step(
        title: const Text("Identity Verification"),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Upload documents to verify identity"),
            const SizedBox(height: 10),
            // Aadhaar
            _buildUploadButton(
              "Aadhaar Card",
              _aadhaarUploaded,
              () => _uploadFile('Aadhaar'),
            ),
            const SizedBox(height: 10),
            // PAN
            _buildUploadButton(
              "PAN Card",
              _panUploaded,
              () => _uploadFile('PAN'),
            ),
            const SizedBox(height: 10),
            // Driving License
            _buildUploadButton(
              "Driving License",
              _licenseUploaded,
              () => _uploadFile('Driving License'),
            ),
          ],
        ),
        isActive: _currentStep >= 1,
        state: (_aadhaarUploaded && _panUploaded && _licenseUploaded)
            ? StepState.complete
            : StepState.indexed,
      ),

      // Step 3: Bank Details
      Step(
        title: const Text("Bank Details"),
        content: Column(
          children: [
            TextField(
              controller: _holderNameController,
              decoration: const InputDecoration(
                labelText: "Account Holder Name",
                border: OutlineInputBorder(),
              ),
              enabled: !_bankVerified,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _accountNoController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Account Number",
                border: OutlineInputBorder(),
              ),
              enabled: !_bankVerified,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _ifscController,
              decoration: const InputDecoration(
                labelText: "IFSC Code",
                border: OutlineInputBorder(),
              ),
              enabled: !_bankVerified,
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _bankVerified ? null : _verifyBank,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _bankVerified ? Colors.green : Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: Text(_bankVerified ? "Verified" : "Verify Bank Details"),
              ),
            ),
          ],
        ),
        isActive: _currentStep >= 2,
        state: _bankVerified ? StepState.complete : StepState.indexed,
      ),

      // Step 4: Work Skill Proof
      Step(
        title: const Text("Work Skill Proof"),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Upload certificates or past work photos"),
            const SizedBox(height: 10),
            _buildUploadButton(
              "Skill Proof",
              _skillProofUploaded,
              () => _uploadFile('Skill Proof'),
            ),
          ],
        ),
        isActive: _currentStep >= 3,
        state: _skillProofUploaded ? StepState.complete : StepState.indexed,
      ),

      // Step 5: Selfie Verification
      Step(
        title: const Text("Selfie Verification"),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Take a selfie to verify your identity"),
            const SizedBox(height: 10),
            Center(
              child: _selfieTaken
                  ? const CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.green,
                      child: Icon(Icons.check, size: 40, color: Colors.white),
                    )
                  : const Icon(
                      Icons.camera_front,
                      size: 80,
                      color: Colors.grey,
                    ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selfieTaken ? null : _takeSelfie,
                child: Text(_selfieTaken ? "Selfie Verified" : "Take Selfie"),
              ),
            ),
          ],
        ),
        isActive: _currentStep >= 4,
        state: _selfieTaken ? StepState.complete : StepState.indexed,
      ),
    ];
  }

  Widget _buildUploadButton(
    String label,
    bool isUploaded,
    VoidCallback onPressed,
  ) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: isUploaded ? null : onPressed,
            icon: Icon(isUploaded ? Icons.check : Icons.upload_file),
            label: Text(isUploaded ? "$label Uploaded" : "Upload $label"),
            style: ElevatedButton.styleFrom(
              backgroundColor: isUploaded ? Colors.green : Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("KYC Verification"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: widget.isWorkerMode ? Colors.blue[50] : Colors.green[50],
            child: Column(
              children: [
                Icon(
                  widget.isWorkerMode ? Icons.engineering : Icons.person_search,
                  size: 40,
                  color: widget.isWorkerMode ? Colors.blue : Colors.green,
                ),
                const SizedBox(height: 8),
                Text(
                  "Verifying as ${widget.isWorkerMode ? 'Worker' : 'Work Giver'}",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: widget.isWorkerMode
                        ? Colors.blue[800]
                        : Colors.green[800],
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Complete these steps to unlock full features",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          Expanded(
            child: Stepper(
              type: StepperType.vertical,
              currentStep: _currentStep,
              onStepContinue: () {
                // Step 0: Phone
                if (_currentStep == 0 && !_phoneVerified) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please verify phone number')),
                  );
                  return;
                }
                // Step 1: Identity (Aadhaar, PAN, License)
                if (_currentStep == 1) {
                  if (!_aadhaarUploaded || !_panUploaded || !_licenseUploaded) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please upload all identity documents'),
                      ),
                    );
                    return;
                  }
                }
                // Step 2: Bank
                if (_currentStep == 2 && !_bankVerified) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please verify bank details')),
                  );
                  return;
                }
                // Step 3: Skill Proof
                if (_currentStep == 3 && !_skillProofUploaded) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please upload skill proof')),
                  );
                  return;
                }
                // Step 4: Selfie
                if (_currentStep == 4 && !_selfieTaken) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please take a selfie')),
                  );
                  return;
                }

                if (_currentStep < 4) {
                  setState(() {
                    _currentStep += 1;
                  });
                } else {
                  // Complete
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('KYC Submitted Successfully!'),
                    ),
                  );
                  Navigator.pop(context);
                }
              },
              onStepCancel: () {
                if (_currentStep > 0) {
                  setState(() {
                    _currentStep -= 1;
                  });
                } else {
                  Navigator.pop(context);
                }
              },
              controlsBuilder: (context, details) {
                return Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: details.onStepContinue,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                          ),
                          child: Text(
                            _currentStep == 4 ? "Submit" : "Continue",
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (_currentStep > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: details.onStepCancel,
                            child: const Text("Back"),
                          ),
                        ),
                    ],
                  ),
                );
              },
              steps: _getSteps(),
            ),
          ),
        ],
      ),
    );
  }
}
