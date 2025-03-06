import { useState, useEffect } from 'react'
import { Routes, Route, Navigate } from 'react-router-dom'
import { Container } from '@mui/material'
import LoginPage from './pages/LoginPage'
import ProfilePage from './pages/ProfilePage'
import ChangeRequestDetailsPage from './pages/ChangeRequestDetailsPage'
import Layout from './components/Layout'
import { AuthProvider, useAuth } from './contexts/AuthContext'

// Protected route component
const ProtectedRoute = ({ children }: { children: React.ReactNode }) => {
  const { isAuthenticated } = useAuth()
  
  if (!isAuthenticated) {
    return <Navigate to="/login" replace />
  }
  
  return <>{children}</>
}

function App() {
  const [isLoading, setIsLoading] = useState(true)
  
  useEffect(() => {
    // Simulate loading resources
    const timer = setTimeout(() => {
      setIsLoading(false)
    }, 1000)
    
    return () => clearTimeout(timer)
  }, [])
  
  if (isLoading) {
    return <div>Loading...</div>
  }
  
  return (
    <AuthProvider>
      <Routes>
        <Route path="/login" element={<LoginPage />} />
        <Route path="/" element={
          <ProtectedRoute>
            <Layout>
              <Container maxWidth="lg" sx={{ mt: 4, mb: 4 }}>
                <ProfilePage />
              </Container>
            </Layout>
          </ProtectedRoute>
        } />
        <Route path="/change-requests/:id" element={
          <ProtectedRoute>
            <Layout>
              <Container maxWidth="lg" sx={{ mt: 4, mb: 4 }}>
                <ChangeRequestDetailsPage />
              </Container>
            </Layout>
          </ProtectedRoute>
        } />
        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
    </AuthProvider>
  )
}

export default App 