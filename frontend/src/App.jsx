import { useState } from 'react'
import './App.css'

function App() {
  const [formData, setFormData] = useState({
    number: '',
    date: new Date().toISOString().split('T')[0],
    payee_name: '',
    payee_address: '',
    payor_name: '',
    payor_address: '',
    bank_name: '',
    bank_address: '',
    bank_fraction: '',
    routing_number: '',
    account_number: '',
    amount: '',
    memo: ''
  })

  const [loading, setLoading] = useState(false)
  const [message, setMessage] = useState(null)
  const [pdfUrl, setPdfUrl] = useState(null)

  const handleChange = (e) => {
    const { name, value } = e.target
    setFormData(prev => ({
      ...prev,
      [name]: value
    }))
  }

  const handleSubmit = async (e) => {
    e.preventDefault()
    setLoading(true)
    setMessage(null)
    setPdfUrl(null)

    try {
      const response = await fetch('/api/generate-check', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(formData)
      })

      const data = await response.json()

      if (data.success) {
        setMessage({ type: 'success', text: 'Check generated successfully!' })

        // Convert base64 to blob and create URL
        const byteCharacters = atob(data.pdf)
        const byteNumbers = new Array(byteCharacters.length)
        for (let i = 0; i < byteCharacters.length; i++) {
          byteNumbers[i] = byteCharacters.charCodeAt(i)
        }
        const byteArray = new Uint8Array(byteNumbers)
        const blob = new Blob([byteArray], { type: 'application/pdf' })
        const url = URL.createObjectURL(blob)
        setPdfUrl(url)
      } else {
        setMessage({ type: 'error', text: `Error: ${data.error}` })
      }
    } catch (error) {
      setMessage({ type: 'error', text: `Failed to generate check: ${error.message}` })
    } finally {
      setLoading(false)
    }
  }

  const handleReset = () => {
    setFormData({
      number: '',
      date: new Date().toISOString().split('T')[0],
      payee_name: '',
      payee_address: '',
      payor_name: '',
      payor_address: '',
      bank_name: '',
      bank_address: '',
      bank_fraction: '',
      routing_number: '',
      account_number: '',
      amount: '',
      memo: ''
    })
    setMessage(null)
    setPdfUrl(null)
  }

  const downloadPdf = () => {
    if (pdfUrl) {
      const link = document.createElement('a')
      link.href = pdfUrl
      link.download = `check-${formData.number || Date.now()}.pdf`
      link.click()
    }
  }

  return (
    <div className="app">
      <div className="container">
        <h1>Check Writer</h1>
        <p className="subtitle">Fill out the form below to generate a professional check in PDF format</p>

        <form onSubmit={handleSubmit}>
          <div className="form-section">
            <h2>Check Information</h2>
            <div className="form-row">
              <div className="form-group">
                <label htmlFor="number">Check Number *</label>
                <input
                  type="text"
                  id="number"
                  name="number"
                  value={formData.number}
                  onChange={handleChange}
                  required
                  placeholder="12345"
                />
              </div>
              <div className="form-group">
                <label htmlFor="date">Date *</label>
                <input
                  type="date"
                  id="date"
                  name="date"
                  value={formData.date}
                  onChange={handleChange}
                  required
                />
              </div>
            </div>
            <div className="form-row">
              <div className="form-group">
                <label htmlFor="amount">Amount *</label>
                <input
                  type="text"
                  id="amount"
                  name="amount"
                  value={formData.amount}
                  onChange={handleChange}
                  required
                  placeholder="1003.23"
                />
              </div>
              <div className="form-group">
                <label htmlFor="memo">Memo</label>
                <input
                  type="text"
                  id="memo"
                  name="memo"
                  value={formData.memo}
                  onChange={handleChange}
                  placeholder="Memo: Void after 60 days"
                />
              </div>
            </div>
          </div>

          <div className="form-section">
            <h2>Payee Information</h2>
            <div className="form-row single">
              <div className="form-group">
                <label htmlFor="payee_name">Payee Name *</label>
                <input
                  type="text"
                  id="payee_name"
                  name="payee_name"
                  value={formData.payee_name}
                  onChange={handleChange}
                  required
                  placeholder="John Smith"
                />
              </div>
            </div>
            <div className="form-row single">
              <div className="form-group">
                <label htmlFor="payee_address">Payee Address</label>
                <textarea
                  id="payee_address"
                  name="payee_address"
                  value={formData.payee_address}
                  onChange={handleChange}
                  placeholder="123 Main Street&#10;City, State, Zip"
                />
              </div>
            </div>
          </div>

          <div className="form-section">
            <h2>Payor Information</h2>
            <div className="form-row single">
              <div className="form-group">
                <label htmlFor="payor_name">Payor Name *</label>
                <input
                  type="text"
                  id="payor_name"
                  name="payor_name"
                  value={formData.payor_name}
                  onChange={handleChange}
                  required
                  placeholder="Payor Name"
                />
              </div>
            </div>
            <div className="form-row single">
              <div className="form-group">
                <label htmlFor="payor_address">Payor Address</label>
                <textarea
                  id="payor_address"
                  name="payor_address"
                  value={formData.payor_address}
                  onChange={handleChange}
                  placeholder="456 Company Ave&#10;City, State, Zip"
                />
              </div>
            </div>
          </div>

          <div className="form-section">
            <h2>Bank Information</h2>
            <div className="form-row single">
              <div className="form-group">
                <label htmlFor="bank_name">Bank Name *</label>
                <input
                  type="text"
                  id="bank_name"
                  name="bank_name"
                  value={formData.bank_name}
                  onChange={handleChange}
                  required
                  placeholder="Bank of America"
                />
              </div>
            </div>
            <div className="form-row single">
              <div className="form-group">
                <label htmlFor="bank_address">Bank Address</label>
                <textarea
                  id="bank_address"
                  name="bank_address"
                  value={formData.bank_address}
                  onChange={handleChange}
                  placeholder="789 Bank Street&#10;City, State, Zip"
                />
              </div>
            </div>
            <div className="form-row">
              <div className="form-group">
                <label htmlFor="bank_fraction">Bank Fraction</label>
                <input
                  type="text"
                  id="bank_fraction"
                  name="bank_fraction"
                  value={formData.bank_fraction}
                  onChange={handleChange}
                  placeholder="12-9876/1234"
                />
              </div>
              <div className="form-group">
                <label htmlFor="routing_number">Routing Number *</label>
                <input
                  type="text"
                  id="routing_number"
                  name="routing_number"
                  value={formData.routing_number}
                  onChange={handleChange}
                  required
                  placeholder="123456789"
                  maxLength="9"
                />
              </div>
            </div>
            <div className="form-row single">
              <div className="form-group">
                <label htmlFor="account_number">Account Number *</label>
                <input
                  type="text"
                  id="account_number"
                  name="account_number"
                  value={formData.account_number}
                  onChange={handleChange}
                  required
                  placeholder="123456789"
                />
              </div>
            </div>
          </div>

          <div className="button-group">
            <button type="button" className="btn-secondary" onClick={handleReset}>
              Reset Form
            </button>
            <button type="submit" className="btn-primary" disabled={loading}>
              {loading ? 'Generating...' : 'Generate Check'}
            </button>
          </div>
        </form>

        {loading && <div className="loading">Generating your check...</div>}

        {message && (
          <div className={`message ${message.type}`}>
            {message.text}
          </div>
        )}

        {pdfUrl && (
          <div className="pdf-viewer">
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '15px' }}>
              <h3>Preview</h3>
              <button type="button" className="btn-primary" onClick={downloadPdf}>
                Download PDF
              </button>
            </div>
            <iframe src={pdfUrl} title="Check Preview" />
          </div>
        )}
      </div>
    </div>
  )
}

export default App
