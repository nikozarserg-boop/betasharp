namespace BetaSharp.Client.Rendering.Core;

/// <summary>
/// A helper class to collect IDisposable GPU resources and dispose of them asynchronously
/// after a few frames, ensuring they are no longer in use by the GPU.
/// </summary>
public static class GPUResourceCollector
{
    private static readonly List<(IDisposable Resource, int FrameCount)> s_disposalQueue = [];
    private static int _frameCounter;
    private const int DISPOSAL_DELAY = 3; // Number of frames to wait before disposal

    /// <summary>
    /// Enqueues a resource for deferred disposal.
    /// </summary>
    public static void Enqueue(IDisposable? resource)
    {
        if (resource == null) return;
        lock (s_disposalQueue)
        {
            s_disposalQueue.Add((resource, _frameCounter));
        }
    }

    /// <summary>
    /// Updates the frame counter and disposes of any resources that have waited long enough.
    /// Should be called once per frame (e.g. at the start or end of the frame).
    /// </summary>
    public static void Update()
    {
        _frameCounter++;
        lock (s_disposalQueue)
        {
            for (int i = s_disposalQueue.Count - 1; i >= 0; i--)
            {
                (IDisposable? resource, int frame) = s_disposalQueue[i];
                if (_frameCounter - frame >= DISPOSAL_DELAY)
                {
                    resource.Dispose();
                    s_disposalQueue.RemoveAt(i);
                }
            }
        }
    }

    /// <summary>
    /// Immediately disposes of all remaining queued resources.
    /// Should be called during shutdown.
    /// </summary>
    public static void Flush()
    {
        lock (s_disposalQueue)
        {
            foreach ((IDisposable? resource, int _) in s_disposalQueue)
            {
                resource.Dispose();
            }
            s_disposalQueue.Clear();
        }
    }
}
