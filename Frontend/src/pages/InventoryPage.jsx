import React, { useEffect, useState, useMemo } from 'react';
import { motion } from 'framer-motion';
import { Search, Plus, AlertTriangle, Package, Edit2, ChevronDown } from 'lucide-react';
import { getInventory, addProduct, adjustStock } from '../services/inventoryService.js';
import { getStockStatusLabel, getStockStatusColor, STOCK_STATUS } from '../models/productModel.js';
import { formatCurrency } from '../utils/formatCurrency.js';
import Badge from '../components/common/Badge.jsx';
import EmptyState from '../components/common/EmptyState.jsx';
import LoadingSpinner from '../components/common/LoadingSpinner.jsx';
import Modal from '../components/common/Modal.jsx';
import Button from '../components/common/Button.jsx';
import Input from '../components/common/Input.jsx';
import { useApp } from '../context/AppContext.jsx';

const CATEGORIES = ['All', 'Staples', 'Snacks', 'Dairy', 'Beverages', 'Personal Care', 'General'];

function AddProductForm({ onSave, onClose }) {
  const [form, setForm] = useState({ name: '', category: 'General', quantity: '', unit: 'pcs', selling_price: '', purchase_price: '', low_stock_threshold: 10 });
  const [saving, setSaving] = useState(false);
  const [errors, setErrors] = useState({});

  function validate() {
    const e = {};
    if (!form.name.trim()) e.name = 'Product name is required';
    if (!form.quantity || isNaN(form.quantity) || Number(form.quantity) < 0) e.quantity = 'Enter a valid quantity';
    return e;
  }

  async function handleSave() {
    const e = validate();
    if (Object.keys(e).length) { setErrors(e); return; }
    setSaving(true);
    try {
      const product = await addProduct({ ...form, quantity: Number(form.quantity), selling_price: Number(form.selling_price), purchase_price: Number(form.purchase_price) });
      onSave(product);
    } finally {
      setSaving(false);
    }
  }

  const set = (k, v) => setForm(f => ({ ...f, [k]: v }));

  return (
    <div className="space-y-4">
      <Input label="Product Name" value={form.name} onChange={e => set('name', e.target.value)} error={errors.name} required id="new-product-name" placeholder="e.g. Amul Milk 1L" />
      <div className="grid grid-cols-2 gap-3">
        <div>
          <label className="label">Category</label>
          <select className="input" value={form.category} onChange={e => set('category', e.target.value)} id="new-product-category">
            {CATEGORIES.slice(1).map(c => <option key={c}>{c}</option>)}
          </select>
        </div>
        <Input label="Unit" value={form.unit} onChange={e => set('unit', e.target.value)} id="new-product-unit" placeholder="pcs / kg / ltr" />
      </div>
      <div className="grid grid-cols-2 gap-3">
        <Input label="Current Quantity" type="number" min="0" value={form.quantity} onChange={e => set('quantity', e.target.value)} error={errors.quantity} required id="new-product-qty" />
        <Input label="Low Stock Alert at" type="number" min="1" value={form.low_stock_threshold} onChange={e => set('low_stock_threshold', Number(e.target.value))} id="new-product-threshold" />
      </div>
      <div className="grid grid-cols-2 gap-3">
        <Input label="Purchase Price (₹)" type="number" min="0" value={form.purchase_price} onChange={e => set('purchase_price', e.target.value)} id="new-product-cost" />
        <Input label="Selling Price (₹)" type="number" min="0" value={form.selling_price} onChange={e => set('selling_price', e.target.value)} id="new-product-price" />
      </div>
      <div className="flex gap-2 pt-2">
        <Button variant="secondary" onClick={onClose} className="flex-1">Cancel</Button>
        <Button variant="primary" loading={saving} onClick={handleSave} className="flex-1">Add Product</Button>
      </div>
    </div>
  );
}

export default function InventoryPage() {
  const [products, setProducts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [category, setCategory] = useState('All');
  const [showLowOnly, setShowLowOnly] = useState(false);
  const [showAddModal, setShowAddModal] = useState(false);
  const { addNotification } = useApp();

  useEffect(() => {
    loadProducts();
  }, []);

  async function loadProducts() {
    setLoading(true);
    try {
      const data = await getInventory();
      setProducts(data);
    } finally {
      setLoading(false);
    }
  }

  const filtered = useMemo(() => {
    let p = products;
    if (search) p = p.filter(prod => prod.name.toLowerCase().includes(search.toLowerCase()));
    if (category !== 'All') p = p.filter(prod => prod.category === category);
    if (showLowOnly) p = p.filter(prod => prod.stockStatus !== STOCK_STATUS.IN_STOCK);
    return p;
  }, [products, search, category, showLowOnly]);

  const lowStockCount = products.filter(p => p.stockStatus !== STOCK_STATUS.IN_STOCK).length;

  function handleProductAdded(product) {
    setProducts(prev => [product, ...prev]);
    setShowAddModal(false);
    addNotification({ type: 'success', title: 'Product Added', message: `${product.name} added to inventory.` });
  }

  return (
    <div className="space-y-5 max-w-7xl mx-auto">
      {/* Low stock alert banner */}
      {lowStockCount > 0 && (
        <div className="flex items-center gap-3 px-4 py-3 rounded-xl" style={{ background: '#fef3c7', border: '1px solid #fde68a' }}>
          <AlertTriangle size={18} style={{ color: '#d97706', flexShrink: 0 }} />
          <p className="text-sm font-medium" style={{ color: '#92400e' }}>
            <strong>{lowStockCount} item{lowStockCount > 1 ? 's' : ''}</strong> need restocking.
            <button onClick={() => setShowLowOnly(true)} className="ml-2 underline font-semibold">View now</button>
          </p>
        </div>
      )}

      {/* Header + controls */}
      <div className="flex flex-col sm:flex-row gap-3 items-start sm:items-center justify-between">
        <div>
          <h2 className="text-h2 text-slate-800">Inventory</h2>
          <p className="text-sm text-slate-400">{products.length} products tracked</p>
        </div>
        <Button icon={Plus} onClick={() => setShowAddModal(true)} id="add-product-btn">Add Product</Button>
      </div>

      {/* Filters */}
      <div className="card p-4 flex flex-col sm:flex-row gap-3">
        <div className="relative flex-1">
          <Search size={15} className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" />
          <input value={search} onChange={e => setSearch(e.target.value)} placeholder="Search products…" className="input pl-9" id="inventory-search" />
        </div>
        <select value={category} onChange={e => setCategory(e.target.value)} className="input w-auto" aria-label="Filter by category">
          {CATEGORIES.map(c => <option key={c}>{c}</option>)}
        </select>
        <button
          onClick={() => setShowLowOnly(!showLowOnly)}
          className={`btn gap-2 flex-shrink-0 ${showLowOnly ? 'btn-primary' : 'btn-secondary'} text-sm`}
        >
          <AlertTriangle size={14} /> Low Stock{showLowOnly ? ' (Active)' : ''}
        </button>
      </div>

      {/* Grid */}
      {loading ? (
        <LoadingSpinner message="Loading inventory…" />
      ) : filtered.length === 0 ? (
        <EmptyState icon={Package} title="No products found" description="Add your first product or clear the search filters." action={<Button icon={Plus} onClick={() => setShowAddModal(true)}>Add Product</Button>} />
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
          {filtered.map((product, i) => (
            <motion.div
              key={product.id}
              initial={{ opacity: 0, y: 12 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: i * 0.04 }}
              className="card p-4 hover:shadow-md transition-all"
            >
              <div className="flex items-start justify-between mb-3">
                <div className="w-10 h-10 rounded-xl flex items-center justify-center" style={{ background: 'var(--color-primary-light)' }}>
                  <Package size={18} style={{ color: 'var(--color-primary)' }} />
                </div>
                <Badge variant={getStockStatusColor(product.stockStatus)} dot>
                  {getStockStatusLabel(product.stockStatus)}
                </Badge>
              </div>
              <h3 className="font-semibold text-slate-800 text-sm mb-0.5 leading-snug">{product.name}</h3>
              <p className="text-xs text-slate-400 mb-3">{product.category}</p>

              {/* Stock bar */}
              <div className="mb-3">
                <div className="flex justify-between text-xs mb-1">
                  <span className="text-slate-500">Stock</span>
                  <span className="font-semibold text-slate-700">{product.quantity} {product.unit}</span>
                </div>
                <div className="h-1.5 rounded-full bg-slate-100 overflow-hidden">
                  <div className="h-full rounded-full transition-all" style={{
                    width: `${Math.min(100, (product.quantity / (product.lowStockThreshold * 3)) * 100)}%`,
                    background: product.stockStatus === STOCK_STATUS.OUT_OF_STOCK ? '#ef4444'
                      : product.stockStatus === STOCK_STATUS.LOW_STOCK ? '#f59e0b'
                      : '#10b981',
                  }} />
                </div>
                {product.stockStatus === STOCK_STATUS.LOW_STOCK && (
                  <p className="text-xs text-amber-600 mt-1 font-medium">Alert: below {product.lowStockThreshold} {product.unit}</p>
                )}
              </div>

              <div className="flex justify-between text-xs">
                {product.sellingPrice > 0 && (
                  <div>
                    <span className="text-slate-400">Sell Price</span>
                    <p className="font-bold text-slate-800">{formatCurrency(product.sellingPrice)}</p>
                  </div>
                )}
                {product.purchasePrice > 0 && (
                  <div className="text-right">
                    <span className="text-slate-400">Cost</span>
                    <p className="font-bold text-slate-600">{formatCurrency(product.purchasePrice)}</p>
                  </div>
                )}
              </div>
            </motion.div>
          ))}
        </div>
      )}

      {/* Add Product Modal */}
      <Modal isOpen={showAddModal} onClose={() => setShowAddModal(false)} title="Add New Product" size="md">
        <AddProductForm onSave={handleProductAdded} onClose={() => setShowAddModal(false)} />
      </Modal>
    </div>
  );
}
