# Attachment Management for Bug Bounty Reports

## Expert Role

You are a senior security documentation specialist with deep expertise in evidence management, digital forensics presentation, and attachment optimization for vulnerability disclosure. You understand that attachments are not supplementary — they are the evidentiary backbone of any bug bounty report. A well-organized attachment set transforms a claim into proof, while poorly managed attachments undermine even the most severe findings. Your mastery encompasses naming conventions, format selection, redaction protocols, size optimization, and organizational architecture that enables triagers to efficiently validate findings.

## Core Concepts

### The Evidentiary Role of Attachments

Attachments serve multiple critical functions in bug bounty reports. They provide proof that the vulnerability exists, demonstrate the exploitation path, document the impact scope, and create an audit trail for severity assessment. Without attachments, reports are claims. With proper attachments, reports are evidence packages. The triager's job is to validate your finding — make their job easy and your chances of acceptance increase dramatically.

Attachments also serve a persuasion function. A clear screenshot of admin access obtained through an authentication bypass is more compelling than any written description. The visual evidence creates an immediate understanding that technical descriptions sometimes fail to convey. This persuasion function operates on both conscious and unconscious levels — triagers are more likely to rate severity accurately when they can see the impact visually.

### Naming Conventions and Their Impact

Attachment naming is not cosmetic. When a triager downloads a report's attachments, filenames are the first organizational signal. `screenshot_1.png` communicates nothing. `step3_auth_bypass_response.png` communicates the attachment's role in the reproduction sequence. Professional naming demonstrates thoroughness and makes the triager's job significantly easier.

Naming conventions should be consistent across all reports. Develop a personal convention and stick to it. Consistency creates predictability for triagers who review multiple reports from you. The convention should encode: sequence position, content description, and file type.

### Size Limits and Optimization

Bug bounty platforms impose attachment size limits that vary by platform and plan. HackerOne typically allows up to 10MB per attachment with total report size limits. Bugcrowd has similar constraints. Exceeding these limits requires either splitting attachments or optimizing them. Understanding these limits and optimizing accordingly prevents submission failures and ensures your complete evidence package reaches the triager.

Optimization does not mean compromising quality. Screenshots can be compressed significantly without losing readability. Videos can be trimmed to show only relevant sections. Captures can be filtered to include only pertinent data. The goal is to reduce size while preserving — or even enhancing — evidentiary value.

### Format Selection Strategy

The choice of attachment format affects usability, compatibility, and evidentiary value. PNG is ideal for screenshots where text clarity matters. JPEG is acceptable for photographs but degrades text readability. GIF is useful for short animations but has color limitations. Video formats should balance quality with file size. PDF is appropriate for multi-page documentation. ZIP archives are useful for bundling related attachments.

Format selection should consider the triager's experience. A triager opening a report on a mobile device may struggle with large PNG screenshots. A triager in a corporate environment may be unable to open unfamiliar formats. Choosing universally accessible formats maximizes the likelihood that your evidence is reviewed as intended.

### Redaction Requirements and Techniques

Redaction is both a legal requirement and an ethical obligation. PII of other users must be redacted. Credentials that could be used maliciously must be redacted. Session tokens that could be replayed must be redacted. The challenge is redacting enough to protect sensitive data while leaving sufficient evidence to validate the vulnerability.

Effective redaction uses consistent visual indicators (black bars, blur, pixelation) that clearly show data was redacted without obscuring the surrounding context. Partial redaction — showing that data exists while hiding its value — is often more effective than full redaction, which can make it unclear what was redacted.

### Attachment Organization Architecture

Reports with multiple attachments need logical organization. The triager should be able to follow the attachment sequence alongside the reproduction steps without confusion. Organization options include: sequential numbering, step-matching labels, and categorical grouping. The choice depends on the report structure and vulnerability complexity.

Effective organization creates a narrative flow in the attachments themselves. When viewed in sequence, the attachments should tell the story of the vulnerability from discovery through impact. This narrative flow reduces the cognitive load on triagers and makes the evidence more compelling.

### Video Attachment Considerations

Video attachments are powerful for demonstrating complex attack chains, race conditions, or multi-step exploitation. However, they present unique challenges: file size, playback compatibility, and the inability to skip to relevant sections efficiently. Videos should be trimmed to the minimum necessary length, include chapter markers where possible, and be accompanied by timestamped descriptions in the report body.

### Screenshot Best Practices

Screenshots are the most common attachment type. Best practices include: capturing the full browser window (including URL bar) for context, highlighting the relevant portion of the screen, annotating key elements, and ensuring text is readable at the captured resolution. Screenshots should be large enough to read but not so large that they require scrolling.

### Capture Tool Selection

Different capture needs require different tools. Browser developer tools for network captures. Screen recording software for dynamic demonstrations. Screenshot tools with annotation capabilities. Command-line output capture for terminal-based exploitation. Each tool produces different output formats with different characteristics.

### Attachment Versioning

When updating reports based on triager feedback, attachment versioning prevents confusion. Use naming conventions that indicate version: `step3_v2.png` or `proof_v1.mp4`. Clear versioning ensures the triager knows which attachments are current and which are superseded.

## Prerequisites

### Platform Knowledge
1. Understanding of each platform's attachment size limits
2. Knowledge of supported file formats per platform
3. Familiarity with platform-specific attachment upload interfaces
4. Understanding of how platforms handle attachment access permissions

### Technical Skills
1. Proficiency with screenshot capture tools
2. Video recording and editing basics
3. Image compression and optimization
4. PDF creation and manipulation
5. Archive creation (ZIP, 7z)

### Security Awareness
1. Understanding of PII identification and redaction requirements
2. Knowledge of credential and token sensitivity
3. Awareness of legal requirements for evidence handling
4. Understanding of responsible disclosure implications

### Tool Proficiency
1. Screenshot tools (Snipping Tool, Greenshot, Lightshot)
2. Video recording (OBS, Camtasia, Loom)
3. Image editing (GIMP, Paint.NET, Photoshop)
4. PDF tools (Adobe Acrobat, PDF24)
5. Archive tools (7-Zip, WinRAR)

## Methodology

### Phase 1: Evidence Collection Planning

**Step 1: Evidence Audit**
Before collecting attachments, list every piece of evidence needed to prove the vulnerability. For each item, determine the optimal format. This planning step prevents haphazard collection that misses critical evidence or captures unnecessary data.

**Step 2: Collection Environment Setup**
Prepare a clean testing environment. Close unnecessary browser tabs, hide bookmarks, ensure the recording area is clean. A cluttered environment in screenshots or recordings suggests careless testing and undermines credibility.

**Step 3: Capture Tool Configuration**
Configure your capture tools before testing begins. Set screenshot shortcuts, configure video recording parameters, ensure annotation tools are ready. Mid-test tool configuration disrupts the testing flow and risks missing critical moments.

### Phase 2: Evidence Collection

**Step 4: Sequential Capture**
Capture evidence in the exact order of reproduction steps. Each step should have a corresponding attachment. This one-to-one mapping between steps and attachments makes the reproduction path crystal clear.

**Step 5: Context Preservation**
Every capture should include sufficient context. For web vulnerabilities, this means the URL bar, relevant headers, and response content. For API vulnerabilities, this means the request, response, and relevant parameters. For system vulnerabilities, this means the terminal output and system state.

**Step 6: Impact Documentation**
After demonstrating exploitation, capture evidence of impact. This might include: extracted data (redacted), modified records, access to restricted areas, or any other observable consequence. Impact evidence is often the most persuasive attachment.

**Step 7: Scope Boundary Evidence**
If the vulnerability affects multiple endpoints or components, capture evidence across the scope. This demonstrates thoroughness and helps the triager understand the full impact surface.

### Phase 3: Evidence Processing

**Step 8: Redaction Application**
Apply redaction consistently across all attachments. Use the same redaction method (black bar, blur, pixelation) for consistency. Ensure redaction covers: other users' PII, active credentials, session tokens, internal infrastructure details not relevant to the finding.

**Step 9: Annotation and Highlighting**
Add annotations to direct the triager's attention to the relevant portion of each attachment. Use arrows, boxes, circles, or text labels. Annotations should enhance, not obscure, the evidence. Keep annotations minimal and focused.

**Step 10: Size Optimization**
Compress attachments to the minimum acceptable quality. For screenshots, reduce dimensions to the minimum readable size. For videos, reduce resolution and frame rate to acceptable minimums. For captures, filter to include only relevant data.

**Step 11: Format Conversion**
Convert attachments to the most appropriate format for the platform and audience. Ensure compatibility across operating systems and browsers. Prefer formats that render inline on the platform rather than requiring download.

### Phase 4: Evidence Organization

**Step 12: Naming Convention Application**
Apply your naming convention to all attachments. Ensure names are descriptive, sequential, and consistent. Remove default names from capture tools (e.g., `Screenshot_2024-01-15_142345.png`).

**Step 13: Attachment Sequencing**
Order attachments to match the reproduction steps. If using multiple attachment types (screenshots, captures, videos), interleave them in the order they are referenced in the report.

**Step 14: Reference Mapping**
In the report body, reference each attachment by name. Create a clear mapping between text descriptions and visual evidence. The triager should never wonder which attachment corresponds to which step.

**Step 15: Archive Creation**
If submitting multiple attachments, consider creating a numbered archive. However, verify that the platform supports archive uploads and that triagers can easily extract contents. Some platforms prefer individual attachments over archives.

### Phase 5: Quality Verification

**Step 16: Readability Check**
Review every attachment at its final size and format. Ensure all text is readable, all annotations are clear, and all evidence is visible. What looks clear at full resolution may be illegible after compression.

**Step 17: Completeness Check**
Verify that every reproduction step has a corresponding attachment. Verify that every claim in the impact section has supporting evidence. Verify that the attachment sequence tells a complete story.

**Step 18: Redaction Verification**
Review all redactions to ensure they cover all sensitive data. Verify that redactions do not inadvertently obscure evidence. Check that redaction methods are consistent.

**Step 19: Compatibility Check**
Test attachments on multiple platforms if possible. Open them in different browsers, on different operating systems, and at different resolutions. Ensure they render correctly in the bug bounty platform's interface.

**Step 20: Final Size Verification**
Verify total attachment size is within platform limits. If over the limit, determine which attachments can be further optimized or which are least essential and can be removed.

## Tool Arsenal

### Screenshot Tools
1. **Greenshot** — Free, lightweight, with annotation capabilities
2. **Lightshot** — Quick capture with instant annotation and upload
3. **Snipping Tool (Windows)** — Built-in, basic but reliable
4. **Skitch (Mac)** — Clean annotation tools with sharing
5. **ShareX** — Advanced capture with scrolling capture, screen recording
6. **Nimbus Screenshot** — Browser extension with annotation
7. **Awesome Screenshot** — Browser extension with editing
8. **TechSmith Capture** — Free screen capture with cloud sharing
9. **FastStone Capture** — Lightweight with scrolling capture
10. **PicPick** — Feature-rich with color picker and pixel ruler

### Video Recording Tools
11. **OBS Studio** — Free, open-source, highly configurable
12. **Camtasia** — Professional recording and editing
13. **Loom** — Quick recording with cloud sharing
14. **Bandicam** — Lightweight with high-quality output
15. **ScreenPal (formerly Screencast-O-Matic)** — Simple web-based recording
16. **Xbox Game Bar (Windows)** — Built-in, basic recording
17. **QuickTime (Mac)** — Built-in, simple recording
18. **CamStudio** — Free, open-source, basic
19. **VLC** — Can record screen with advanced options
20. **FFmpeg** — Command-line video capture and processing

### Image Editing and Optimization
21. **GIMP** — Free, powerful image editing
22. **Paint.NET** — Free, lightweight editing
23. **TinyPNG** — Web-based PNG/JPEG compression
24. **ImageOptim (Mac)** — Batch compression
25. **JPEGmini** — JPEG-specific optimization
26. **SVGOMG** — SVG optimization
27. **Photoshop** — Professional editing (paid)
28. **Photopea** — Free web-based Photoshop alternative
29. **IrfanView** — Lightweight image viewer with batch processing
30. **XnConvert** — Batch image conversion and optimization

### PDF Tools
31. **PDF24** — Free, comprehensive PDF toolkit
32. **Smallpdf** — Web-based PDF compression and manipulation
33. **Adobe Acrobat** — Professional PDF tools (paid)
34. **PDFsam** — Split, merge, extract PDF pages
35. **Sejda** — Web-based PDF editing

### Archive Tools
36. **7-Zip** — Free, supports multiple formats
37. **WinRAR** — Popular, supports RAR and ZIP
38. **PeaZip** — Free, open-source archive manager
39. **Bandizip** — Fast, lightweight archiver
40. **ZIP (built-in)** — Native OS support

### Annotation and Markup Tools
41. **Skitch** — Clean annotation with arrows and shapes
42. **Pixlr** — Web-based image editing with annotation
43. **Markdown screenshots** — Text-based annotation in report
44. **Draw.io** — Diagram creation for complex attack chains
45. **Excalidraw** — Hand-drawn style diagrams
46. **diagrams.net** — Free, browser-based diagramming
47. **Figma** — Design tool useful for diagram creation
48. **Marp** — Markdown-based presentation for attack narratives
49. **Recordit** — GIF creation from screen recordings
50. **LICEcap** — Lightweight GIF recording

## Case Studies

### Case Study 1: Naming Convention Transformation

**Before:** Report submitted with attachments named `1.png`, `2.png`, `3.png`, `4.png`, `5.png`, `capture.har`, `output.txt`.

**After:** Report restructured with attachments named `01_step1_login_page.png`, `02_step2_admin_panel_access.png`, `03_step3_user_data_extraction.png`, `04_step4_database_dump_evidence.png`, `05_impact_scope_summary.png`, `06_network_capture_filtered.har`, `07_extracted_credentials_redacted.txt`.

**Impact:** The renamed attachments reduced triage time from 45 minutes to 15 minutes. The triager noted: "Clear reproduction steps with corresponding well-labeled evidence. Excellent report structure."

### Case Study 2: Video Optimization for Complex Chain

**Context:** A multi-step attack chain required 4 minutes of video to demonstrate fully. The original 1080p recording was 85MB, exceeding platform limits.

**Solution:** Trimmed to 2 minutes showing only the critical steps. Reduced resolution to 720p. Added chapter markers in the report body with timestamps. Compressed using H.264 codec.

**Result:** Final video was 12MB, within platform limits. Chapter markers allowed the triager to jump to relevant sections. The report was accepted as Critical within 24 hours, with the triager specifically praising the evidence quality.

### Case Study 3: Redaction Balance

**Context:** A vulnerability exposed user PII including names, emails, phone numbers, and physical addresses. The researcher needed to demonstrate the data exposure while protecting user privacy.

**Solution:** Created screenshots showing the API response with all fields visible, then applied targeted redaction: full names shown as "John D*" (first name, last initial), emails as "john***@email.com", phone numbers as "***-***-1234", addresses fully redacted. Each redacted field was labeled with its data type.

**Result:** The triager could verify the vulnerability's impact (full PII exposure) while user privacy was maintained. The report was accepted without any PII concerns, and the partial redaction approach was praised as a model for other researchers.

### Case Study 4: Multi-Format Evidence Package

**Context:** A race condition vulnerability required showing that two concurrent requests both succeeded. Screenshots alone could not demonstrate concurrency.

**Solution:** Included: (1) Screenshots of both successful responses, (2) A HAR file showing the timing of both requests, (3) A terminal capture of the concurrent curl commands with timestamps, (4) A summary diagram showing the race condition timeline.

**Result:** The multi-format evidence package clearly demonstrated the race condition. The diagram was particularly effective in helping the triager understand the timing issue. The report was accepted as High severity with a $3,000 bounty.

### Case Study 5: Attachment Size Management

**Context:** A server-side request forgery vulnerability produced extensive output showing internal network scanning results. The full output was 45MB.

**Solution:** Created a summary screenshot showing the key findings (internal services discovered, sensitive data accessed). Provided a filtered HAR file showing only the SSRF requests and responses (2MB). Included a text file with the full scan results compressed to 500KB. Organized the evidence to lead with the most impactful summary.

**Result:** The triager could quickly assess the severity from the summary, investigate the technical details in the HAR file, and reference the full scan when needed. The total attachment size was under 3MB. The report was accepted as Critical.

### Case Study 6: Cross-Platform Compatibility

**Context:** A researcher created a report with attachments that looked perfect on their Mac but rendered poorly on the triager's Windows system. Specifically, a PNG with a custom font was unreadable after platform compression.

**Solution:** The researcher switched to system fonts for all annotated screenshots, tested rendering on both platforms, and used the platform's preview function before submission. They also provided an alternative text description for any attachment that might have rendering issues.

**Result:** The revised report rendered correctly on all platforms. The lesson learned was to test attachments on multiple platforms before submission.

### Case Study 7: Screenshot Context Problem

**Context:** A researcher submitted a report with a screenshot showing an admin panel. However, the URL bar was cropped out, and the screenshot only showed the panel content without the surrounding page context.

**Solution:** Re-captured the screenshot with the full browser window visible, including the URL bar, browser tabs, and page context. Added an annotation highlighting the admin panel within the full page.

**Result:** The triager could immediately verify the URL (confirming it was on the target domain), see the admin panel in context (confirming it was part of the application), and understand the page layout. The original report required follow-up questions; the revised version was accepted immediately.

### Case Study 8: HAR File Sanitization

**Context:** A network capture (HAR file) was attached to demonstrate an API vulnerability. The HAR file contained session cookies, API keys, and other sensitive headers that were not relevant to the finding.

**Solution:** Created a sanitized version of the HAR file that preserved the request URLs, parameters, and response bodies while removing: cookies, authorization headers, API keys, and internal headers. Documented the sanitization in the report.

**Result:** The sanitized HAR file was sufficient to validate the vulnerability while protecting sensitive authentication data. The report was accepted, and the sanitization approach was noted as a best practice.

### Case Study 9: Attachment Organization for Multi-Endpoint Finding

**Context:** A vulnerability affected five different API endpoints. Each endpoint had different exploitation steps and different impact.

**Solution:** Created a directory structure in a ZIP archive: `endpoint1/` through `endpoint5/`, each containing screenshots, captures, and a brief README. The report body included a summary table linking each endpoint to its corresponding directory.

**Result:** The organized archive made it easy for the triager to assess each endpoint independently. The table provided a quick overview. The report was accepted with all five endpoints confirmed.

### Case Study 10: Evidence Sequencing for Business Logic

**Context:** A business logic vulnerability allowed price manipulation through a sequence of cart operations. The vulnerability required showing the state at each step.

**Solution:** Created numbered screenshots for each step: initial cart state, modified parameters, intermediate state, final state, and confirmation email. Each screenshot included the URL, relevant form fields, and the resulting state. Added a summary diagram showing the flow.

**Result:** The sequential evidence clearly showed the logic flaw. The diagram provided a quick overview. The triager could follow the reproduction steps without ambiguity. The report was accepted as High severity.

## Advanced Techniques

### Evidence Narrative Construction

Construct your attachments as a visual narrative. The first attachment should establish the initial state (before exploitation). Subsequent attachments should show the progression through the attack. The final attachment should show the impact (after exploitation). This narrative arc makes the evidence more compelling and easier to follow.

### Strategic Annotation Placement

Place annotations strategically to guide the triager's eye. Annotations should be near — not on — the evidence they describe. Use consistent colors: red for critical elements, blue for informational elements, green for success indicators. Avoid cluttering screenshots with too many annotations.

### Comparative Evidence

When the vulnerability involves a before/after state, present attachments as a comparison. Side-by-side screenshots showing the state before and after exploitation are more compelling than sequential screenshots that require the triager to remember the previous state.

### Progressive Disclosure in Attachments

Layer evidence from summary to detail. Start with a summary screenshot that shows the overall impact. Follow with detailed evidence for each claim. End with raw data for thorough verification. This layering serves different levels of triager interest.

### Cross-Reference Linking

Create explicit links between report sections and attachments. "As shown in `step3_admin_access.png`" is better than assuming the triager will figure out which attachment corresponds to which step. These links reduce cognitive load and prevent confusion.

### Attachment Metadata

When possible, include metadata that demonstrates the evidence is genuine: timestamps, request IDs, correlation IDs, session identifiers. This metadata makes the evidence harder to dispute and easier to cross-reference with server logs.

### Dynamic Evidence Generation

For vulnerabilities that produce different output each time, capture the specific output from your test and reference it by timestamp or ID. This allows the triager to verify against their own logs.

## Detection

### Attachment Quality Assessment Checklist

1. Every reproduction step has a corresponding attachment
2. All text in screenshots is readable at the attachment's resolution
3. All redactions are consistent in style and coverage
4. All annotations enhance rather than obscure evidence
5. File names are descriptive and follow a consistent convention
6. Total size is within platform limits
7. Formats are compatible with the platform and common operating systems
8. Video attachments are trimmed to minimum necessary length
9. HAR files are sanitized of sensitive authentication data
10. The attachment sequence tells a complete story

### Common Attachment Deficiencies

Missing URL bar context in screenshots, unreadable text due to compression, inconsistent redaction methods, missing annotations on critical evidence, non-descriptive filenames, attachments exceeding platform size limits, and incompatible formats.

## Impact

### Triage Speed Correlation

Well-organized attachments reduce triage time by 40-60%. Triagers can validate findings faster when evidence is clear, labeled, and sequenced. Faster triage means faster resolution and faster payment.

### Severity Assessment Accuracy

Proper evidence helps triagers assign accurate severity. When impact is clearly demonstrated through attachments, triagers have the information needed to rate severity appropriately. Inadequate evidence leads to conservative severity ratings.

### Follow-Up Question Reduction

Complete attachment sets eliminate the need for follow-up questions. Each follow-up question delays resolution by days. Investing in thorough attachment collection upfront pays dividends in faster resolution.

### Researcher Credibility

Consistent, high-quality attachments build researcher credibility. Programs notice researchers who submit thorough evidence packages. This credibility influences future interactions and can lead to private program invitations.

## Pitfalls

### Pitfall 1: Cropping Too Aggressively
Removing context (URL bar, page layout) from screenshots makes them harder to validate. Always include sufficient context.

### Pitfall 2: Over-Compression
Compressing screenshots until text is unreadable defeats the purpose. Optimize for size, not at the expense of readability.

### Pitfall 3: Inconsistent Redaction
Using different redaction methods across attachments (blur in one, black bar in another) looks careless. Maintain consistency.

### Pitfall 4: Missing Sequential Context
Showing the final state without the initial state makes it harder to understand the vulnerability's effect. Always show before and after.

### Pitfall 5: Large Video Files
Recording entire testing sessions without trimming wastes platform storage and triager time. Edit videos to show only relevant sections.

### Pitfall 6: Non-Descriptive Names
Using default capture tool names (Screenshot_2024.png) provides no information about the attachment's content or purpose.

### Pitfall 7: Unsanitized HAR Files
Attaching raw network captures with credentials and tokens is a security risk and violates responsible disclosure principles.

### Pitfall 8: Platform Incompatibility
Creating attachments that only render correctly on one operating system or browser limits accessibility. Test cross-platform.

### Pitfall 9: No Annotations
Submitting screenshots without annotations forces the triager to search for the relevant information. Guide their attention.

### Pitfall 10: Over-Attaching
Including every possible piece of evidence, including irrelevant captures, dilutes the important evidence. Be selective and relevant.

## Integration

### With Report Structure
Attachments should be referenced explicitly in the report body. Each attachment reference should include a description of what the attachment shows and why it is relevant.

### With Reproduction Steps
Each reproduction step should have a corresponding attachment. The step description and attachment should complement each other — the text explains what to do, the attachment shows the result.

### With Impact Assessment
Impact claims should be supported by impact evidence. If you claim "full database access," the attachment should show evidence of that access.

### With Severity Justification
Attachments that demonstrate severity support your CVSS assessment. Impact evidence justifies Confidentiality/Integrity/Availability ratings.

### With Platform Guidelines
Each platform has specific attachment guidelines. Ensure your attachment strategy complies with platform-specific requirements.

## Reporting

### Attachment Quality Metrics

Track: number of attachments per report, average attachment size, attachment-to-step ratio, follow-up question rate (correlated with attachment quality), and triage time (correlated with evidence quality).

### Documentation Standards

Maintain a personal attachment standards document. Include naming conventions, format preferences, redaction protocols, and quality checklists. Update this document based on outcomes.

### Continuous Improvement

Review accepted reports from top researchers for attachment strategies. Analyze rejected reports for attachment deficiencies. Continuously refine your approach based on outcomes.

## Labs

### Lab 1: Naming Convention Development
Develop a personal naming convention for attachments. Test it across five different vulnerability classes. Refine based on clarity and consistency.

### Lab 2: Redaction Protocol Practice
Take five different types of sensitive data and practice redacting them consistently across multiple attachment formats. Ensure redaction is effective without obscuring context.

### Lab 3: Video Optimization
Record a 3-minute demonstration of a vulnerability. Optimize it to under 2MB while maintaining readability. Add chapter markers and timestamp references.

### Lab 4: Cross-Platform Testing
Create a set of attachments and test them on two different operating systems. Document any rendering differences and adjust accordingly.

### Lab 5: Complete Evidence Package
Create a complete evidence package for a complex vulnerability including screenshots, HAR file, video, and summary diagram. Ensure all attachments are properly named, sized, and organized.

### Lab 6: Size Budget Exercise
Given a 10MB total size limit, create an evidence package for a vulnerability that requires 15MB of raw evidence. Prioritize, compress, and organize to fit within the limit.

### Lab 7: Annotation Optimization
Create three versions of the same screenshot: no annotations, minimal annotations, and excessive annotations. Have peers evaluate which is most effective.

## Ethics

### Privacy Protection
Redact all PII of other users. Never include unredacted personal information in attachments. This is both an ethical obligation and a platform requirement.

### Credential Handling
Never include active credentials in attachments. If demonstrating credential exposure, show the credential in a redacted form that proves exposure without enabling misuse.

### Responsible Evidence Handling
Store attachments securely. Delete test data after submission. Do not share evidence with parties outside the vulnerability disclosure process.

### Honest Representation
Do not manipulate screenshots or recordings to exaggerate impact. Evidence should faithfully represent the vulnerability's actual behavior.

### Scope Compliance
Only attach evidence that is within the program's scope. Evidence of out-of-scope vulnerabilities should not be included in reports.

## Cheat Sheet

### Naming Convention Template
```
[sequence]_[step/section]_[description].[format]
Example: 03_step2_admin_panel_access.png
Example: 05_impact_scope_summary.png
```

### Format Selection Guide
| Content Type | Recommended Format | Alternative |
|-------------|-------------------|-------------|
| Screenshot (text) | PNG | SVG |
| Screenshot (photo) | JPEG | WebP |
| Animation | GIF | MP4 |
| Video demonstration | MP4 | WebM |
| Multi-page document | PDF | — |
| Multiple files | ZIP | 7z |
| Network capture | HAR | — |
| Terminal output | TXT | PNG |

### Size Optimization Targets
- Screenshots: Under 500KB each
- Videos: Under 5MB each, under 2 minutes
- HAR files: Under 2MB (filtered)
- Total per report: Under 10MB

### Redaction Checklist
- [ ] User names partially redacted (first name, last initial)
- [ ] User emails partially redacted (first part, domain visible)
- [ ] User phone numbers partially redacted (last 4 digits visible)
- [ ] User addresses fully redacted
- [ ] Session tokens fully redacted
- [ ] API keys fully redacted
- [ ] Passwords fully redacted
- [ ] Internal IPs partially redacted (if not relevant to finding)
- [ ] Server hostnames redacted (if internal and not relevant)

### Quick Quality Checklist
- [ ] Every step has a corresponding attachment
- [ ] All text is readable
- [ ] Redaction is consistent
- [ ] Names are descriptive
- [ ] Size is within limits
- [ ] Formats are compatible
- [ ] Sequence is logical
- [ ] Annotations guide attention
- [ ] Context is preserved
- [ ] Impact is demonstrated
