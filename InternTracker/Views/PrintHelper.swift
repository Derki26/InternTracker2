import Foundation
import UIKit

enum PrintHelper {

    static func printHTML(jobName: String, html: String) {
        let formatter = UIMarkupTextPrintFormatter(markupText: html)

        let controller = UIPrintInteractionController.shared
        controller.printFormatter = formatter

        let info = UIPrintInfo(dictionary: nil)
        info.jobName = jobName
        info.outputType = .general
        controller.printInfo = info

        controller.present(animated: true, completionHandler: nil)
    }

    static func buildProjectLogHTML(
        internName: String,
        projectName: String,
        plannedHours: Double,
        totalHours: Double,
        from: Date?,
        to: Date?,
        entries: [DailyActivity]
    ) -> String {

        let df = DateFormatter()
        df.dateStyle = .medium

        let rangeText: String = {
            if let from, let to {
                return "\(df.string(from: from)) – \(df.string(from: to))"
            }
            return "All Dates"
        }()

        let rows = entries.map { e in
            let date = df.string(from: e.date)
            let hrs = String(format: "%.2f", e.hours)
            let note = escape(e.note.isEmpty ? "—" : e.note)

            return """
            <tr>
                <td>\(escape(date))</td>
                <td style="text-align:right;">\(hrs)</td>
                <td>\(note)</td>
            </tr>
            """
        }.joined(separator: "\n")

        return """
        <html>
        <head>
            <meta charset="utf-8"/>
            <style>
                body { font-family: -apple-system, Helvetica, Arial; padding: 18px; }
                h1 { margin-bottom: 6px; font-size: 18px; }
                .meta { margin-bottom: 12px; font-size: 12px; color: #444; }
                table { width: 100%; border-collapse: collapse; font-size: 12px; }
                th, td { border-bottom: 1px solid #ddd; padding: 8px 6px; }
                th { background: #f5f5f5; text-align: left; }
            </style>
        </head>
        <body>
            <h1>Intern Weekly Activity Report/h1>

            <div class="meta">
                <b>Intern:</b> \(escape(internName.isEmpty ? "Intern" : internName))<br/>
                <b>Project:</b> \(escape(projectName))<br/>
                <b>Date Range:</b> \(escape(rangeText))<br/>
                <b>Planned Hours:</b> \(String(format: "%.2f", plannedHours))
                &nbsp; | &nbsp;
                <b>Logged Hours:</b> \(String(format: "%.2f", totalHours))
            </div>

            <table>
                <thead>
                    <tr>
                        <th style="width: 18%;">Date</th>
                        <th style="width: 10%; text-align:right;">Hours</th>
                        <th>Activity / Note</th>
                    </tr>
                </thead>
                <tbody>
                    \(rows)
                </tbody>
            </table>
        </body>
        </html>
        """
    }

    private static func escape(_ s: String) -> String {
        s.replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&#39;")
    }
}

