import { describe, it, expect, vi } from "vitest";

// Mock contract interactions
const mockTxSender = "ST1234567890abcdef1234567890abcdef";
const mockContractOwner = "ST1234567890abcdef1234567890abcdef";

// Mocked data
const mockCourses = new Map();
const mockBalances = new Map();
const mockUserProgress = new Map();

// Utility functions
const resetMocks = () => {
  mockCourses.clear();
  mockBalances.clear();
  mockUserProgress.clear();
};

const mockMapGet = (map: Map<any, any>, key: any) => map.get(key);
const mockMapSet = (map: Map<any, any>, key: any, value: any) => map.set(key, value);
const mockMapDelete = (map: Map<any, any>, key: any) => map.delete(key);

const isOwner = (sender: string) => sender === mockContractOwner;

// Mocked contract functions
const createCourse = (courseId: number, title: string, reward: number, sender: string) => {
  if (!isOwner(sender)) return { error: "err-owner-only" };
  if (mockCourses.has(courseId)) return { error: "err-already-exists" };
  if (title.trim().length === 0 || title.length > 100) return { error: "err-invalid-input" };
  if (reward < 1 || reward > 1000000) return { error: "err-invalid-input" };

  mockMapSet(mockCourses, courseId, { title, reward, active: true });
  return { success: true };
};

const updateCourse = (courseId: number, newTitle: string | null, newReward: number | null, sender: string) => {
  if (!isOwner(sender)) return { error: "err-owner-only" };
  if (!mockCourses.has(courseId)) return { error: "err-not-found" };

  const course = mockMapGet(mockCourses, courseId);
  const updatedTitle = newTitle ?? course.title;
  const updatedReward = newReward ?? course.reward;

  if (newTitle && (newTitle.trim().length === 0 || newTitle.length > 100))
    return { error: "err-invalid-input" };
  if (newReward && (newReward < 1 || newReward > 1000000)) return { error: "err-invalid-input" };
  if (!newTitle && !newReward) return { error: "err-no-changes" };

  mockMapSet(mockCourses, courseId, { ...course, title: updatedTitle, reward: updatedReward });
  return { success: true };
};

const toggleCourseStatus = (courseId: number, sender: string) => {
  if (!isOwner(sender)) return { error: "err-owner-only" };
  if (!mockCourses.has(courseId)) return { error: "err-not-found" };

  const course = mockMapGet(mockCourses, courseId);
  mockMapSet(mockCourses, courseId, { ...course, active: !course.active });
  return { success: true };
};

// Test suite
describe("LearnQ Smart Contract", () => {
  beforeEach(() => {
    resetMocks();
  });

  describe("createCourse", () => {
    it("should create a new course", () => {
      const result = createCourse(1, "Intro to Blockchain", 500, mockContractOwner);
      expect(result).toEqual({ success: true });
      expect(mockCourses.has(1)).toBeTruthy();
    });

    it("should fail if the user is not the contract owner", () => {
      const result = createCourse(1, "Intro to Blockchain", 500, "ST000000000000000000000000000000");
      expect(result).toEqual({ error: "err-owner-only" });
    });

    it("should fail if the course already exists", () => {
      createCourse(1, "Intro to Blockchain", 500, mockContractOwner);
      const result = createCourse(1, "Intro to Blockchain", 500, mockContractOwner);
      expect(result).toEqual({ error: "err-already-exists" });
    });

    it("should validate title and reward", () => {
      const invalidTitle = createCourse(1, "", 500, mockContractOwner);
      const invalidReward = createCourse(1, "Valid Title", 0, mockContractOwner);
      expect(invalidTitle).toEqual({ error: "err-invalid-input" });
      expect(invalidReward).toEqual({ error: "err-invalid-input" });
    });
  });

  describe("updateCourse", () => {
    it("should update course details", () => {
      createCourse(1, "Intro to Blockchain", 500, mockContractOwner);
      const result = updateCourse(1, "Advanced Blockchain", 1000, mockContractOwner);
      expect(result).toEqual({ success: true });
      const updatedCourse = mockMapGet(mockCourses, 1);
      expect(updatedCourse.title).toBe("Advanced Blockchain");
      expect(updatedCourse.reward).toBe(1000);
    });

    it("should fail if no changes are provided", () => {
      createCourse(1, "Intro to Blockchain", 500, mockContractOwner);
      const result = updateCourse(1, null, null, mockContractOwner);
      expect(result).toEqual({ error: "err-no-changes" });
    });
  });

  describe("toggleCourseStatus", () => {
    it("should toggle course status", () => {
      createCourse(1, "Intro to Blockchain", 500, mockContractOwner);
      const result = toggleCourseStatus(1, mockContractOwner);
      expect(result).toEqual({ success: true });
      const course = mockMapGet(mockCourses, 1);
      expect(course.active).toBeFalsy();
    });

    it("should fail if the user is not the contract owner", () => {
      createCourse(1, "Intro to Blockchain", 500, mockContractOwner);
      const result = toggleCourseStatus(1, "ST000000000000000000000000000000");
      expect(result).toEqual({ error: "err-owner-only" });
    });
  });
});
