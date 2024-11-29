import 'package:flutter/material.dart';
import 'package:gift_shop/APIs/complaint_api.dart';
import 'package:gift_shop/drawer/complaint_details_page.dart';

class ComplaintPage extends StatefulWidget {
  const ComplaintPage({super.key});

  @override
  _ComplaintPageState createState() => _ComplaintPageState();
}

class _ComplaintPageState extends State<ComplaintPage> {
  final TextEditingController _complaintController = TextEditingController();
  List<Map<String, dynamic>> _complaints = [];

  @override
  void initState() {
    super.initState();
    _fetchComplaints();
  }

  Future<void> _fetchComplaints() async {
    try {
      final response = await fetchComplaints();
      if (response['status'] == 'success') {
        setState(() {
          _complaints = List<Map<String, dynamic>>.from(response['data']);
        });
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch complaints');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching complaints: $e')),
      );
    }
  }

  Future<void> _submitComplaint(BuildContext context) async {
    final complaint = _complaintController.text;

    if (complaint.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complaint description cannot be empty')),
      );
      return;
    }

    try {
      final response = await submitComplaint(complaint);

      if (response['status'] == 'success') {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Complaint Submitted"),
            content: const Text(
                "Thank you for your complaint. We will get back to you soon."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
        );
        _complaintController.clear();
        _fetchComplaints(); // Refresh complaints after submission.
      } else {
        throw Exception(response['message'] ?? 'Unknown error');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting complaint: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Complaint Page"),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Color.fromRGBO(187, 222, 251, 1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.edit, color: Colors.teal, size: 28),
                          SizedBox(width: 8),
                          Text(
                            "Submit Your Complaint",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _complaintController,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          labelText: "Complaint Description",
                          border: OutlineInputBorder(),
                          hintText: "Describe your issue in detail",
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: ElevatedButton(
                          onPressed: () => _submitComplaint(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 20),
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                          child: const Text(
                            "Submit",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                "Previous Complaints",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _complaints.isEmpty
                  ? const Center(
                      child: Text(
                        "No complaints found.",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _complaints.length,
                      itemBuilder: (context, index) {
                        final complaint = _complaints[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ComplaintDetailsPage(complaint: complaint),
                              ),
                            );
                          },
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16.0),
                              title: Text(
                                "Complaint: ${complaint['Complaint']}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                "Reply: ${complaint['Reply'] ?? 'No reply yet'}",
                                style: const TextStyle(color: Colors.grey),
                              ),
                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.grey,
                                size: 16,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
