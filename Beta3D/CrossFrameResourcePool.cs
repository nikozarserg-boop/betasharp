namespace Beta3D;

public class CrossFrameResourcePool(int framesToKeepResource) : IGraphicsResourceAllocator, IDisposable
{
    protected class ResourceEntry<T>(IResourceDescriptor<T> descriptor, T value, int framesToLive) : IDisposable
    {
        public IResourceDescriptor<T> Descriptor { get; } = descriptor;
        public T Value { get; } = value;
        public int FramesToLive = framesToLive;

        public void Dispose() => Descriptor.Free(Value);
    }

    private readonly int _framesToKeepResource = framesToKeepResource;
    private readonly List<ResourceEntry<object>> _pool = [];

    protected IEnumerable<ResourceEntry<object>> Entries => _pool;

    public void EndFrame()
    {
        for (int i = _pool.Count - 1; i >= 0; i--)
        {
            ResourceEntry<object> entry = _pool[i];

            if (entry.FramesToLive-- == 0)
            {
                entry.Dispose();
                _pool.RemoveAt(i);
            }
        }
    }

    public T Acquire<T>(IResourceDescriptor<T> descriptor)
    {
        T resource = AcquireWithoutPreparing(descriptor);
        descriptor.Prepare(resource);
        return resource;
    }

    private T AcquireWithoutPreparing<T>(IResourceDescriptor<T> descriptor)
    {
        for (int i = 0; i < _pool.Count; i++)
        {
            ResourceEntry<object> entry = _pool[i];
            if (descriptor.CanUsePhysicalResource((IResourceDescriptor<T>)entry.Descriptor))
            {
                _pool.RemoveAt(i);
                return (T)entry.Value;
            }
        }
        return descriptor.Allocate();
    }

    public void Release<T>(IResourceDescriptor<T> descriptor, T resource) => _pool.Insert(0, new((IResourceDescriptor<object>)descriptor, resource!, _framesToKeepResource));

    public void Clear()
    {
        foreach (ResourceEntry<object> entry in _pool)
        {
            entry.Dispose();
        }

        _pool.Clear();
    }

    public void Dispose()
    {
        GC.SuppressFinalize(this);
        Clear();
    }
}
